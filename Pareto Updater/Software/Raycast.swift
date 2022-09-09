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

class AppRaycast: AppUpdater {
    static let sharedInstance = AppRaycast()

    override var appName: String { "Raycast" }
    override var appMarketingName: String { "Raycast" }
    override var appBundle: String { "com.raycast.macos" }
    override var description: String { "Raycast is a blazingly fast, totally extendable launcher." }
    override var latestURL: URL {
        URL(string: "https://www.raycast.com/download")!
    }

    override var latestURLExtension: String {
        "dmg"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://www.raycast.com/download"
        let versionRegex = Regex("Raycast_v?([\\.\\d]+)_")
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
