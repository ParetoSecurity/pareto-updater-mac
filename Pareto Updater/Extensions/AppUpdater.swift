//
//  AppUpdater.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import Alamofire
import AppKit
import Defaults
import Foundation
import os.log
import Path
import Regex
import SwiftUI

enum AppUpdaterStatus {
    case Idle
    case GatheringInfo
    case DownloadingUpdate
    case InstallingUpdate
    case Updated
    case Failed
}

struct AppStoreResponse: Codable {
    let resultCount: Int
    let results: [AppStoreResult]
}

struct AppStoreResult: Codable {
    let version, wrapperType: String
    let artistID: Int
    let artistName: String

    enum CodingKeys: String, CodingKey {
        case version, wrapperType
        case artistID = "artistId"
        case artistName
    }
}

public class AppUpdater: Hashable, Identifiable, ObservableObject {
    public static func == (lhs: AppUpdater, rhs: AppUpdater) -> Bool {
        lhs.UUID == rhs.UUID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(UUID)
    }

    private(set) var UUID = "UUID"

    var appName: String { "" } // Updater for Pareto
    var appMarketingName: String { "" } // Pareto Updater
    var appBundle: String { "" } // like co.niteo.paretoupdater

    @Published var status: AppUpdaterStatus = .Idle
    @Published var updatable: Bool = false
    @Published var fractionCompleted: Double = 0.0

    var workItem: DispatchWorkItem?

    func getLatestVersion(completion _: @escaping (String) -> Void) {
        fatalError("getLatestVersion() is not implemented")
    }

    var help: String {
        "\(textVersion) Latest: \(latestVersion)"
    }

    var hasUpdate: Bool {
        if let version = currentVersion {
            return latestVersion.versionCompare(version) == .orderedDescending
        }
        return false
    }

    public var usedRecently: Bool {
        if !Defaults[.checkForUpdatesRecentOnly] {
            return true
        }

        if let appPath = applicationPath {
            let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            let attributes = NSMetadataItem(url: URL(fileURLWithPath: appPath))
            guard let lastUse = attributes?.value(forAttribute: "kMDItemLastUsedDate") as? Date else { return false }
            return lastUse >= weekAgo
        }
        return true
    }

    func downloadLatest(completion: @escaping (URL, URL) -> Void) {
        let cachedPath = Constants.cacheFolder.appendingPathComponent("\(appBundle)-\(latestVersion).\(latestURL.pathExtension)")
        if FileManager.default.fileExists(atPath: cachedPath.path), Constants.useCacheFolder {
            os_log("Update from cache at %{public}", cachedPath.debugDescription)
            completion(latestURL, cachedPath)
            return
        }
        // os_log("Update downloadLatest: \(cachedPath.debugDescription) from \(latestURL.debugDescription)")

        AF.download(latestURL).responseData { [self] response in
            do {
                if FileManager.default.fileExists(atPath: cachedPath.path) {
                    try FileManager.default.removeItem(at: cachedPath)
                }
                try FileManager.default.moveItem(atPath: response.fileURL!.path, toPath: cachedPath.path)
                os_log("Update downloadLatest: %{public} from %{public}", cachedPath.debugDescription, self.latestURL.debugDescription)
                completion(latestURL, cachedPath)
                return
            } catch {
                completion(latestURL, response.fileURL!)
                return
            }
        }.downloadProgress { [self] progress in
            self.fractionCompleted = progress.fractionCompleted
        }
    }

    var latestURL: URL {
        fatalError("latestURL() is not implemented")
    }

    func install(sourceFile: URL, appFile: URL) -> AppUpdaterStatus {
        DispatchQueue.main.async { [self] in
            status = .InstallingUpdate
        }

        var needsStart = false
        let processes = NSRunningApplication.runningApplications(withBundleIdentifier: appBundle)
        for process in processes {
            process.forceTerminate()
            needsStart = true
        }

        if sourceFile.pathExtension == "dmg" {
            let mountPoint = URL(string: "/Volumes/" + appBundle)!
            os_log("Mount %{public}s is %{public}s%", appFile.debugDescription, mountPoint.debugDescription)
            if DMGMounter.attach(diskImage: appFile, at: mountPoint) {
                do {
                    let app = try FileManager.default.contentsOfDirectory(at: mountPoint, includingPropertiesForKeys: nil).filter { $0.lastPathComponent.contains(".app") }.first

                    let downloadedAppBundle = Bundle(url: app!)!
                    let installedAppBundle = Bundle(path: applicationPath!)!

                    os_log("Delete installedAppBundle: \(installedAppBundle.description)")
                    try installedAppBundle.path.delete()

                    os_log("Update installedAppBundle: \(installedAppBundle.description) with \(downloadedAppBundle.description)")

                    try downloadedAppBundle.path.copy(to: installedAppBundle.path, overwrite: true)

                    _ = DMGMounter.detach(mountPoint: mountPoint)

                    if needsStart {
                        installedAppBundle.launch()
                    }
                    return AppUpdaterStatus.Updated
                } catch {
                    _ = DMGMounter.detach(mountPoint: mountPoint)
                    os_log("Failed to check for app bundle %{public}s", error.localizedDescription)
                    return AppUpdaterStatus.Failed
                }
            }
        }
        if sourceFile.pathExtension == "zip" || sourceFile.pathExtension.contains("tar") {
            do {
                let app = FileManager.default.unzip(appFile)
                let downloadedAppBundle = Bundle(url: app)!
                let installedAppBundle = Bundle(path: applicationPath!)!
                os_log("Delete installedAppBundle: \(installedAppBundle)")
                try installedAppBundle.path.delete()
                os_log("Update installedAppBundle: \(installedAppBundle) with \(downloadedAppBundle)")
                try downloadedAppBundle.path.copy(to: installedAppBundle.path, overwrite: true)

                // Wait for bundle IO ops to finish
                while FileManager.default.contentsEqual(atPath: installedAppBundle.path.string, andPath: downloadedAppBundle.path.string) {
                    sleep(1)
                }

                try downloadedAppBundle.path.delete()
                if needsStart {
                    installedAppBundle.launch()
                }
                return AppUpdaterStatus.Updated
            } catch {
                os_log("Failed to check for app bundle %{public}s", error.localizedDescription)
                return AppUpdaterStatus.Failed
            }
        }
        return AppUpdaterStatus.Failed
    }

    func updateApp(completion: @escaping (AppUpdaterStatus) -> Void) {
        if !hasUpdate {
            completion(.Idle)
            status = .Idle
            return
        }
        DispatchQueue.main.async { [self] in
            status = .DownloadingUpdate
            fractionCompleted = 0.0
        }

        downloadLatest { sourceFile, appFile in
            let state = self.install(sourceFile: sourceFile, appFile: appFile)
            DispatchQueue.main.async { [self] in
                status = state
                fractionCompleted = 0.0
                completion(state)
            }
        }
    }

    var textVersion: String {
        if let path = applicationPath {
            if let version = Bundle.appVersion(path: path) {
                return version.lowercased()
            }
            return "0.0.0"
        }
        return "0.0.0"
    }

    var currentVersion: String? {
        if !isInstalled {
            return nil
        }

        return textVersion.versionNormalize
    }

    var applicationPath: String? {
        let globalPath = "/Applications/\(appName).app"
        if FileManager.default.fileExists(atPath: globalPath) {
            return globalPath
        }

        let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
        let localPath = "\(homeDirURL.path)/Applications/\(appName).app"
        if FileManager.default.fileExists(atPath: localPath) {
            return localPath
        }

        return nil
    }

    public var isInstalled: Bool {
        applicationPath != nil
    }

    public var icon: NSImage? {
        if !isInstalled {
            return nil
        }
        return Bundle(path: applicationPath!)?.icon
    }

    public var latestVersion: String {
        if let found = try? Constants.versionStorage.existsObject(forKey: appBundle), found {
            return try! Constants.versionStorage.object(forKey: appBundle)
        } else {
            let lock = DispatchSemaphore(value: 0)
            getLatestVersion { [self] version in
                try! Constants.versionStorage.setObject(version, forKey: self.appBundle)
                lock.signal()
            }
            lock.wait()
            return try! Constants.versionStorage.object(forKey: appBundle)
        }
    }
}
