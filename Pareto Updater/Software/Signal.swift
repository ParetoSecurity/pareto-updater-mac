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

class AppSignal: AppUpdater {
    static let sharedInstance = AppSignal(appBundle: "org.whispersystems.signal-desktop")

    override var appName: String { "Signal" }
    override var appMarketingName: String { "Signal" }
    override var description: String { "Signal is a free, privacy-focused messaging and voice talk app." }
    override var latestURL: URL {
        URL(string: "https://updates.signal.org/desktop/signal-desktop-mac-universal-\(latestVersion).dmg")!
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
