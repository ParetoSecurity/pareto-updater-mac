//
//  GoogleChrome.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Alamofire
import AppKit
import Combine
import Foundation
import os.log
import OSLog
import Path
import Regex

class AppZoom: AppUpdater {
    static let sharedInstance = AppZoom()

    override var appName: String { "Zoom.us" }
    override var appMarketingName: String { "Zoom" }
    override var appBundle: String { "us.zoom.xos" }

    private static var HTTPClient = Session(configuration: HTTPConfig)

    private static var HTTPConfig: URLSessionConfiguration {
        let config = URLSessionConfiguration.af.default
        config.headers.add(.userAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"))

        return config
    }

    override var latestURL: URL {
        #if arch(arm64)
            return URL(string: "https://zoom.us/client/latest/zoomusInstallerFull.pkg?archType=arm64")!
        #else
            return URL(string: "https://zoom.us/client/latest/zoomusInstallerFull.pkg")!
        #endif
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://zoom.us/download#client_4meeting"
        let versionRegex = Regex("Version ([\\d.]+)")
        os_log("Requesting %{public}s", url)

        AppZoom.HTTPClient.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let html = response.value ?? "Version 1.11.3 (1065)"
                let version = versionRegex.firstMatch(in: html)?.groups.first?.value ?? "1.11.3"
                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion(version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }

    override func extract(sourceFile _: URL, appFile: URL, needsStart: Bool) -> AppUpdaterStatus {
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory(),
                           isDirectory: true).appendingPathComponent("zoomus")
        try? Path(tempPath.path)?.delete()

        do {
            Process.run(app: "/usr/sbin/pkgutil", args: [
                "--expand",
                appFile.path,
                tempPath.path,

            ])
            Process.run(app: "/usr/bin/tar", args: [
                "xf",
                tempPath
                    .appendingPathComponent("zoomus.pkg", isDirectory: true)
                    .appendingPathComponent("Payload")
                    .path,

                "-C",
                tempPath.path,
            ])

            let app = tempPath.appendingPathComponent("zoom.us.app")

            let downloadedAppBundle = Bundle(url: app)!
            if let installedAppBundle = Bundle(path: applicationPath) {
                os_log("Delete installedAppBundle: \(installedAppBundle.description)")
                try installedAppBundle.path.delete()

                os_log("Update installedAppBundle: \(installedAppBundle.description) with \(downloadedAppBundle.description)")
                try downloadedAppBundle.path.copy(to: installedAppBundle.path, overwrite: true)
                if needsStart {
                    installedAppBundle.launch()
                }
            } else {
                os_log("Install AppBundle \(downloadedAppBundle.description)")
                try downloadedAppBundle.path.copy(to: Path(applicationPath)!, overwrite: true)
            }

            if let bundle = Bundle(path: applicationPath), needsStart {
                bundle.launch()
            }
            try? Path(tempPath.path)?.delete()
            return AppUpdaterStatus.Updated
        } catch {
            try? Path(tempPath.path)?.delete()
            os_log("Failed to check for app bundle %{public}s", error.localizedDescription)
            return AppUpdaterStatus.Failed
        }
    }

    override var textVersion: String {
        if isInstalled {
            if let version = Bundle.appVersion(path: applicationPath) {
                if let v = version.split(separator: " ").first {
                    return String(v).lowercased()
                }
            }
        }
        return "0.0.0"
    }
}
