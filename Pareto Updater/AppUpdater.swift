//
//  AppUpdater.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import Alamofire
import AppKit
import Foundation
import os.log
import Path
import SwiftUI
import Version

enum AppUpdaterStatus {
    case GatheringInfo
    case DownloadingUpdate
    case InstallingUpdate
    case Updated
    case Failed
}

public class AppUpdater: Hashable, Identifiable, ObservableObject {
    public static func == (lhs: AppUpdater, rhs: AppUpdater) -> Bool {
        lhs.UUID == rhs.UUID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(UUID)
    }

    private(set) var UUID = "UUID"
    private(set) var latestVersionCached = "0.0.0"
    var appName: String { "" } // Updater for Pareto
    var appMarketingName: String { "" } // Pareto Updater
    var appBundle: String { "" } // like co.niteo.paretoupdater

    private let cachePath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".pareto-updater").resolvingSymlinksInPath()

    @Published var fetching: Bool = false
    @Published var updatable: Bool = false
    @Published var fractionCompleted: Double = 0.0

    func getLatestVersion(completion _: @escaping (String) -> Void) {
        fatalError("getLatestVersion() is not implemented")
    }

    var help: String {
        "Installed: \(currentVersion), latest: \(latestVersion)"
    }

    func downloadLatest(completion: @escaping (URL, URL) -> Void) {
        let cachedPath = cachePath.appendingPathComponent(latestURL.lastPathComponent)
        if FileManager.default.fileExists(atPath: cachedPath.path) {
            completion(latestURL, cachedPath)
        }
        // os_log("Update downloadLatest: \(cachedPath.debugDescription) from \(latestURL.debugDescription)")

        AF.download(latestURL).responseData { [self] response in
            if !FileManager.default.fileExists(atPath: cachePath.path) {
                do {
                    try FileManager.default.createDirectory(atPath: cachePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
            do {
                if FileManager.default.fileExists(atPath: cachedPath.path) {
                    try FileManager.default.removeItem(atPath: cachedPath.path)
                }
                try FileManager.default.moveItem(atPath: response.fileURL!.path, toPath: cachedPath.path)
                os_log("Update downloadLatest: \(cachedPath.debugDescription) from \(self.latestURL.debugDescription)")
                completion(latestURL, cachedPath)
            } catch {
                completion(latestURL, response.fileURL!)
            }
        }.downloadProgress { [self] progress in
            self.fractionCompleted = progress.fractionCompleted
        }
    }

    var latestURL: URL {
        fatalError("latestURL() is not implemented")
    }

    func updateApp(completion: @escaping (AppUpdaterStatus) -> Void) {
        DispatchQueue.main.async { [self] in
            fetching = true
            fractionCompleted = 0.0
        }

        downloadLatest { [self] sourceFile, appFile in
            DispatchQueue.main.async { [self] in
                fetching = true
                fractionCompleted = 0.5
            }
            let processes = NSRunningApplication.runningApplications(withBundleIdentifier: appBundle)
            for process in processes {
                process.forceTerminate()
            }
            DispatchQueue.main.async { [self] in
                fetching = true
                fractionCompleted = 0.9
            }
            if sourceFile.pathExtension == "dmg" {
                let mountPoint = URL(string: "/Volumes/" + appBundle)!
                os_log("Mount %{public}s is %{public}s%", appFile.debugDescription, mountPoint.debugDescription)
                if DMGMounter.attach(diskImage: appFile, at: mountPoint) {
                    do {
                        let app = try FileManager.default.contentsOfDirectory(at: mountPoint, includingPropertiesForKeys: nil).filter { $0.lastPathComponent.contains(".app") }.first
                        let downloadedAppBundle = Bundle(url: app!)!
                        let installedAppBundle = Bundle(path: applicationPath!)!
                        os_log("Delete installedAppBundle: \(installedAppBundle)")
                        try installedAppBundle.path.delete()
                        os_log("Update installedAppBundle: \(installedAppBundle) with \(downloadedAppBundle)")
                        try downloadedAppBundle.path.copy(to: installedAppBundle.path, overwrite: true)
                        DMGMounter.detach(mountPoint: mountPoint)
                        completion(AppUpdaterStatus.Updated)
                    } catch {
                        DMGMounter.detach(mountPoint: mountPoint)
                        os_log("Failed to check for app bundle %{public}s", error.localizedDescription)
                        completion(AppUpdaterStatus.Failed)
                    }
                }
            }
            if sourceFile.pathExtension == "zip" {
                os_log("Unzipped %{public}s is %{public}s%", appFile.debugDescription)
                do {
                    let app = unzip(sourceFile)
                    let downloadedAppBundle = Bundle(url: app)!
                    let installedAppBundle = Bundle(path: applicationPath!)!
                    os_log("Delete installedAppBundle: \(installedAppBundle)")
                    try installedAppBundle.path.delete()
                    os_log("Update installedAppBundle: \(installedAppBundle) with \(downloadedAppBundle)")
                    try downloadedAppBundle.path.copy(to: installedAppBundle.path, overwrite: true)
                    completion(AppUpdaterStatus.Updated)
                } catch {
                    os_log("Failed to check for app bundle %{public}s", error.localizedDescription)
                    completion(AppUpdaterStatus.Failed)
                }
            }

            DispatchQueue.main.async { [self] in
                fetching = false
                updatable = false
                fractionCompleted = 0.0
            }
        }
    }

    var currentVersion: Version {
        if applicationPath == nil {
            return Version(0, 0, 0)
        }
        var version = (appVersion(path: applicationPath!) ?? "0.0.0").lowercased()
        if version.contains("alpha") {
            version = version.replacingOccurrences(of: "alpha", with: "-alpha")
        }
        if version.contains("beta") {
            version = version.replacingOccurrences(of: "beta", with: "-beta")
        }

        version = version.replacingOccurrences(of: ".-", with: "-")
        return Version(version) ?? Version(0, 0, 0)
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

    public var icon: NSImage {
        let defaultImage = NSImage(systemSymbolName: "app.dashed", accessibilityDescription: nil)!
        if applicationPath != nil {
            return NSWorkspace.shared.icon(forFile: (URL(string: applicationPath!)?.standardizedFileURL.path)!)
        }
        return defaultImage
    }

    public var latestVersion: Version {
        if latestVersionCached != "0.0.0" {
            return Version(latestVersionCached) ?? Version(0, 0, 0)
        }

        var version = Version(0, 0, 0)
        let lock = DispatchSemaphore(value: 0)
        getLatestVersion { [self] latestVersion in
            latestVersionCached = latestVersion
            version = Version(latestVersion) ?? Version(0, 0, 0)
            lock.signal()
        }
        lock.wait()
        return version
    }

    public var usedRecently: Bool {
        if isInstalled {
            let app = applicationPath!
            let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            let attributes = NSMetadataItem(url: URL(fileURLWithPath: app))
            guard let lastUse = attributes?.value(forAttribute: "kMDItemLastUsedDate") as? Date else { return false }
            return lastUse >= weekAgo
        }
        return false
    }
}

func viaEdgeCache(_ url: String) -> String {
    if Constants.useEdgeCache {
        return url.replacingOccurrences(of: "https://", with: "https://pareto-cache.team-niteo.workers.dev/")
    }
    return url
}

private func unzip(_ url: URL) -> URL {
    let proc = Process()
    if #available(OSX 10.13, *) {
        proc.currentDirectoryURL = url.deletingLastPathComponent()
    } else {
        proc.currentDirectoryPath = url.deletingLastPathComponent().path
    }

    proc.launchPath = "/usr/bin/unzip"
    proc.arguments = [url.path]

    func findApp() throws -> URL? {
        let files = try FileManager.default.contentsOfDirectory(at: url.deletingLastPathComponent(), includingPropertiesForKeys: [.isDirectoryKey], options: .skipsSubdirectoryDescendants)
        for url in files {
            guard url.pathExtension == "app" else { continue }
            guard let foo = try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory, foo else { continue }
            return url
        }
        return nil
    }
    proc.launch()
    proc.waitUntilExit()
    return try! findApp()!
}
