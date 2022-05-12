//
//  SublimeText.swift
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
import Regex
import Version

class AppSublimeText: AppUpdater {
    static let sharedInstance = AppSublimeText()

    override var appName: String { "Sublime Text" }
    override var appMarketingName: String { "Sublime Text" }
    override var appBundle: String { "com.sublimetext.4" }

    override var UUID: String {
        "0ae675c9-1fbe-5fcc-8e4a-c0f53f4d8b4d"
    }

    override var latestURL: URL {
        URL(string: "https://download.sublimetext.com/sublime_text_build_\(latestVersionCached.split(separator: ".").joined())_mac.zip")!
    }

    override var currentVersion: Version {
        if applicationPath == nil {
            return Version(0, 0, 0)
        }
        let version = Bundle.appVersion(path: applicationPath ?? "Build 3121")!.split(separator: " ")[1]
        return Version("\(version.prefix(1)).\(version.suffix(3)).0") ?? Version(0, 0, 0)
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache("https://www.sublimetext.com/download")
        let versionRegex = Regex("Build (\\d+)")
        os_log("Requesting %{public}s", url)

        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let yaml = response.value ?? "Build 3121"
                let version = versionRegex.firstMatch(in: yaml)?.groups.first?.value ?? "3121"
                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion("\(version.prefix(1)).\(version.suffix(3)).0")
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }
}
