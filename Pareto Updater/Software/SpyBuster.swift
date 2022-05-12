//
//  Signal.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex
import Version

enum AppUpdaterState: String {
    case GAter
}

class AppSpyBuster: AppUpdater {
    static let sharedInstance = AppSpyBuster()

    override var appName: String { "SpyBuster" }
    override var appMarketingName: String { "SpyBuster" }
    override var appBundle: String { "com.macpaw-labs.snitch" }

    override var UUID: String {
        "d128d7dd-0fc2-42ea-b4a8-81e834485e0a"
    }

    override var latestURL: URL {
        URL(string: "https://dl.devmate.com/com.macpaw-labs.snitch/SpyBuster.zip")!
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache("https://updates.devmate.com/com.macpaw-labs.snitch.xml?test=1&beta=1")
        let versionRegex = Regex("sparkle:shortVersionString=\"([\\.\\d]+)\"")

        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let versionNew = versionRegex.allMatches(in: response.value ?? "")
                if !versionNew.isEmpty {
                    let versions = versionNew.map { $0.groups.first?.value ?? "0.0.0" }
                    let version = versions.sorted().last ?? "0.0.0"
                    os_log("%{public}s sparkle:shortVersionString=%{public}s", self.appBundle, version)
                    completion(version)
                } else {
                    os_log("%{public}s failed:Sparkle=0.0.0", self.appBundle)
                    completion("0.0.0")
                }

            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }
}
