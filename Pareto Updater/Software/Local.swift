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

class AppLocal: AppUpdater {
    static let sharedInstance = AppLocal(appBundle: "com.getflywheel.lightning.local")

    override var appName: String { "Local" }
    override var appMarketingName: String { "Local" }
    override var description: String { "An effortless way to develop WordPress sites locally." }
    override var latestURL: URL {
        URL(string: "https://cdn.localwp.com/stable/latest/mac")!
    }

    override var latestURLExtension: String {
        "dmg"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://cdn.localwp.com/stable/latest/mac"
        let versionRegex = Regex("local-?([\\.\\d]+)-mac")
        os_log("Requesting %{public}s", url)

        AF.request(url, method: .head).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if let url = response.response?.url, response.error == nil {
                let version = versionRegex.firstMatch(in: url.description)?.groups.first?.value ?? "6.4.2"
                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion(version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }
}
