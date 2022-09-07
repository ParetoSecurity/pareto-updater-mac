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

class AppAppCleaner: AppUpdater {
    static let sharedInstance = AppAppCleaner()

    override var appName: String { "AppCleaner" }
    override var appMarketingName: String { "AppCleaner" }
    override var appBundle: String { "net.freemacsoft.AppCleaner" }

    override var latestURL: URL {
        URL(string: "https://freemacsoft.net/downloads/AppCleaner_\(latestVersion).zip")!
    }

    override var latestURLExtension: String {
        "dmg"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://freemacsoft.net/appcleaner/"
        let versionRegex = Regex(">Version ?([\\.\\d]+)<")
        os_log("Requesting %{public}s", url)

        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if let html = response.value, response.error == nil {
                let version = versionRegex.firstMatch(in: html)?.groups.first?.value ?? "3.6"
                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion(version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }
}
