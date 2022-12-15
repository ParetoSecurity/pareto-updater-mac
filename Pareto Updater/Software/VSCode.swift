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

class AppVSCodeApp: AppUpdater {
    static let sharedInstance = AppVSCodeApp(appBundle: "com.microsoft.VSCode")

    override var appName: String { "Visual Studio Code" }
    override var appMarketingName: String { "Visual Studio Code" }
    override var description: String { "Visual Studio Code is a code editor redefined and optimized for building and debugging modern web and cloud applications." }
    override var latestURL: URL {
        URL(string: "https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal")!
    }

    override var latestURLExtension: String {
        "zip"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://code.visualstudio.com/updates/"
        let versionRegex = Regex("<strong>Update ([\\.\\d]+)</strong>")
        os_log("Requesting %{public}s", url)

        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let html = response.value ?? "<strong>Update 1.12.1</strong>"
                let versions = versionRegex.allMatches(in: html).map { $0.groups.first!.value }
                let version = versions.sorted(by: { $0.lowercased().versionCompare($1.lowercased()) == .orderedAscending })
                completion(version.last ?? "1.12.1")
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }
}
