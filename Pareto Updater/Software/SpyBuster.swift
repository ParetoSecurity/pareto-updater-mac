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
        let url = viaEdgeCache("https://updates.signal.org/desktop/latest-mac.yml")
        let versionRegex = Regex("version: ?([\\.\\d]+)")
        os_log("Requesting %{public}s", url)

        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let yaml = response.value ?? "version: 1.25.0"
                let version = versionRegex.firstMatch(in: yaml)?.groups.first?.value ?? "1.25.0"
                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion(version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }
}
