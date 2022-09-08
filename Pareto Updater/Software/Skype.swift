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

class AppSkype: AppUpdater {
    static let sharedInstance = AppSkype()

    override var appName: String { "Skype" }
    override var appMarketingName: String { "Skype" }
    override var appBundle: String { "com.skype.skype" }

    override var latestURL: URL {
        URL(string: "https://get.skype.com/go/getskype-skypeformac")!
    }

    override var latestURLExtension: String {
        "dmg"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://get.skype.com/go/getskype-skypeformac"
        let versionRegex = Regex("Skype-?([\\.\\d]+)\\.dmg") // Skype-8.88.0.401.dmg
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

    override var textVersion: String {
        if isInstalled {
            if let version = Bundle.appVersion(path: applicationPath, key: "CFBundleVersion") {
                return version
            }
            return "0.0.0"
        }
        return "0.0.0"
    }
}
