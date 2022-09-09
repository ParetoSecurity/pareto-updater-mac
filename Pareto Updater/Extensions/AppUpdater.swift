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
    case Installed
    case Failed
    case Unsupported
}

public class AppUpdater: Hashable, Identifiable, ObservableObject {
    public static func == (lhs: AppUpdater, rhs: AppUpdater) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id = UUID()

    var appName: String { "" } // Updater for Pareto
    var appMarketingName: String { "" } // Pareto Updater
    var appBundle: String { "" } // like co.niteo.paretoupdater
    var description: String { "" } // like "this is a great app"

    @Published var status: AppUpdaterStatus = .Idle
    @Published var updatable: Bool = false
    @Published var fractionCompleted: Double = 0.0

    var workItem: DispatchWorkItem?

    func getLatestVersion(completion _: @escaping (String) -> Void) {
        fatalError("getLatestVersion() is not implemented")
    }

    var help: String {
        if textVersion == "0.0.0" {
            return "Installing: \(latestVersion)"
        }
        return "\(textVersion) Latest: \(latestVersion)"
    }

    var latestURLExtension: String {
        latestURL.pathExtension
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

        if isInstalled {
            let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            let attributes = NSMetadataItem(url: applicationPath)
            guard let lastUse = attributes?.value(forAttribute: "kMDItemLastUsedDate") as? Date else { return false }
            return lastUse >= weekAgo
        }
        return true
    }

    public var fromAppStore: Bool {
        if isInstalled {
            let attributes = NSMetadataItem(url: applicationPath)
            guard let hasReceipt = attributes?.value(forAttribute: "kMDItemAppStoreHasReceipt") as? Bool else { return false }
            return hasReceipt
        }
        return false
    }

    func downloadLatest(completion: @escaping (URL, URL) -> Void) {
        let cachedPath = Constants.cacheFolder.appendingPathComponent("\(appBundle)-\(latestVersion).\(latestURLExtension)")
        if FileManager.default.fileExists(atPath: cachedPath.path), Constants.useCacheFolder {
            os_log("Update from cache at %{public}", cachedPath.debugDescription)
            completion(latestURL, cachedPath)
            return
        }
        // os_log("Update downloadLatest: \(cachedPath.debugDescription) from \(latestURL.debugDescription)")
        print("Starting download of \(latestURL.description)")
        AF.download(latestURL).responseData(queue: Constants.httpQueue) { [self] response in
            print("Downloaded \(latestURL.description)")
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

        return extract(sourceFile: sourceFile, appFile: appFile, needsStart: needsStart)
    }

    func extract(sourceFile _: URL, appFile: URL, needsStart: Bool) -> AppUpdaterStatus {
        switch appFile.pathExtension {
        case "dmg":
            let mountPoint = URL(string: "/Volumes/" + appBundle)!
            os_log("Mount %{public}s is %{public}s%", appFile.debugDescription, mountPoint.debugDescription)
            if DMGMounter.attach(diskImage: appFile, at: mountPoint) {
                do {
                    let app = try FileManager.default.contentsOfDirectory(at: mountPoint, includingPropertiesForKeys: nil).filter { $0.lastPathComponent.contains(".app") }.first

                    let downloadedAppBundle = Bundle(url: app!)!
                    if let installedAppBundle = Bundle(url: applicationPath) {
                        if !validate(downloadedAppBundle, installedAppBundle) {
                            os_log("Failed to validate app bundle %{public}s", appBundle)
                            return AppUpdaterStatus.Failed
                        }

                        os_log("Delete installedAppBundle: \(installedAppBundle.description)")
                        try installedAppBundle.path.delete()

                        os_log("Update installedAppBundle: \(installedAppBundle.description) with \(downloadedAppBundle.description)")
                        try downloadedAppBundle.path.copy(to: installedAppBundle.path, overwrite: true)
                        if needsStart {
                            installedAppBundle.launch()
                        }
                    } else {
                        os_log("Install AppBundle \(downloadedAppBundle.description)")
                        try downloadedAppBundle.path.copy(to: Path(url: applicationPath)!, overwrite: true)
                    }
                    _ = DMGMounter.detach(mountPoint: mountPoint)

                    if let bundle = Bundle(url: applicationPath), needsStart {
                        bundle.launch()
                    }

                    return AppUpdaterStatus.Installed
                } catch {
                    _ = DMGMounter.detach(mountPoint: mountPoint)
                    os_log("Failed to check for app bundle %{public}s", error.localizedDescription)
                    return AppUpdaterStatus.Failed
                }
            }
        case "zip", "tar":
            do {
                let app = FileManager.default.unzip(appFile)
                let downloadedAppBundle = Bundle(url: app)!
                if let installedAppBundle = Bundle(url: applicationPath) {
                    if !validate(downloadedAppBundle, installedAppBundle) {
                        os_log("Failed to validate app bundle %{public}s", appBundle)
                        return AppUpdaterStatus.Failed
                    }

                    os_log("Delete installedAppBundle: \(installedAppBundle.description)")
                    try installedAppBundle.path.delete()

                    os_log("Update installedAppBundle: \(installedAppBundle.description) with \(downloadedAppBundle.description)")
                    try downloadedAppBundle.path.copy(to: installedAppBundle.path, overwrite: true)
                    if needsStart {
                        installedAppBundle.launch()
                    }
                } else {
                    os_log("Install AppBundle \(downloadedAppBundle.description)")
                    try downloadedAppBundle.path.copy(to: Path(applicationPath.path)!, overwrite: true)
                }

                try downloadedAppBundle.path.delete()
                if let bundle = Bundle(url: applicationPath), needsStart {
                    bundle.launch()
                }
                return AppUpdaterStatus.Installed
            } catch {
                os_log("Failed to check for app bundle %{public}s", error.localizedDescription)
                return AppUpdaterStatus.Failed
            }
        default:
            return AppUpdaterStatus.Unsupported
        }

        return AppUpdaterStatus.Failed
    }

    func validate(_ b1: Bundle, _ b2: Bundle) -> Bool {
        b1.codeSigningIdentity == b2.codeSigningIdentity
    }

    func updateApp(completion: @escaping (AppUpdaterStatus) -> Void) {
        DispatchQueue.main.async { [self] in
            status = .DownloadingUpdate
            fractionCompleted = 0.0
        }
        downloadLatest { [self] sourceFile, appFile in
            workItem?.cancel()
            workItem = DispatchWorkItem { [self] in

                let state = self.install(sourceFile: sourceFile, appFile: appFile)
                DispatchQueue.main.async { [self] in
                    status = state
                    fractionCompleted = 0.0
                    completion(state)
                }
            }

            workItem?.notify(queue: .main) { [self] in
                status = .Idle
                updatable = false
                fractionCompleted = 0.0
                completion(status)
            }
            DispatchQueue.global(qos: .userInteractive).async(execute: workItem!)
        }
    }

    var textVersion: String {
        if isInstalled {
            if let version = Bundle.appVersion(path: applicationPath) {
                return currentVersionHook(version.versionNormalize)
            }
            return "0.0.0"
        }
        return "0.0.0"
    }

    var currentVersion: String? {
        if !isInstalled {
            return nil
        }

        return textVersion
    }

    var applicationPath: URL {
        URL(fileURLWithPath: "/Applications/\(appName).app")
    }

    public var isInstalled: Bool {
        (try? applicationPath.checkResourceIsReachable()) ?? false
    }

    public var icon: NSImage? {
        if !isInstalled {
            return nil
        }
        return Bundle(url: applicationPath)?.icon
    }

    public var latestVersion: String {
        if let found = try? Constants.versionStorage.existsObject(forKey: appBundle), found {
            return latestVersionHook(try! Constants.versionStorage.object(forKey: appBundle))
        } else {
            let lock = DispatchSemaphore(value: 0)
            DispatchQueue.global(qos: .userInteractive).async { [self] in
                getLatestVersion { [self] version in
                    try! Constants.versionStorage.setObject(version, forKey: self.appBundle)
                    lock.signal()
                }
            }
            lock.wait()
            return latestVersionHook(try! Constants.versionStorage.object(forKey: appBundle))
        }
    }

    public func latestVersionHook(_ version: String) -> String {
        return version
    }

    public func currentVersionHook(_ version: String) -> String {
        return version
    }
}
