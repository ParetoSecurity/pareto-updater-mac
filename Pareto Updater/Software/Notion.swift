//
//  Notion.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppNotion: AppUpdater {
    static let sharedInstance = AppNotion(appBundle: "notion.id")

    override var appName: String { "Notion" }
    override var appMarketingName: String { "Notion" }
    override var description: String { "Write, plan & get organized in one place." }
    override var latestURL: URL {
        #if arch(arm64)
            return URL(string: "https://www.notion.so/desktop/apple-silicon/download")!
        #else
            return URL(string: "https://www.notion.so/desktop/mac/download")!
        #endif
    }

    override var latestURLExtension: String {
        "dmg"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://www.notion.so/desktop/apple-silicon/download"
        let versionRegex = Regex("Notion-?([\\.\\d]+)-arm64") // https://desktop-release.notion-static.com/Notion-2.1.1-arm64.dmg
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
