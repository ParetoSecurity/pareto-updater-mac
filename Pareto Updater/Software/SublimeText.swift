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

class AppSublimeText: AppUpdater {
    static let sharedInstance = AppSublimeText()

    override var appName: String { "Sublime Text" }
    override var appMarketingName: String { "Sublime Text" }
    override var appBundle: String { "com.sublimetext.4" }
    override var description: String { "Sublime Text is a sophisticated text editor for code, markup and prose." }
    override var textVersion: String {
        if isInstalled {
            if let version = Bundle.appVersion(path: applicationPath) {
                if let v = version.split(separator: " ").last {
                    return String(v).lowercased()
                }
            }
        }
        return "0.0.0"
    }

    override var latestURL: URL {
        URL(string: "https://download.sublimetext.com/sublime_text_build_\(latestVersion.split(separator: ".").joined())_mac.zip")!
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
                completion(version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }
}
