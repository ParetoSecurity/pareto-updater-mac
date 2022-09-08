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

class AppTeamViewer: AppUpdater {
    static let sharedInstance = AppTeamViewer()

    override var appName: String { "TeamViewerQS" }
    override var appMarketingName: String { "TeamViewer" }
    override var appBundle: String { "com.teamviewer.teamviewer" }

    override var latestURL: URL {
        URL(string: "https://download.teamviewer.com/download/TeamViewerQS.dmg")!
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://www.teamviewer.com/en/download/mac-os/"
        let versionRegex = Regex("ion: ?([\\.\\d]+)<") // <p>Current version: 15.33.7</p>
        os_log("Requesting %{public}s", url)

        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if let html = response.value, response.error == nil {
                let version = versionRegex.firstMatch(in: html)?.groups.first?.value ?? "6.4.2"
                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion(version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }
}
