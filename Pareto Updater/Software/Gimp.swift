//
//  AppGimp.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppGimp: AppUpdater {
    static let sharedInstance = AppGimp(appBundle: "org.gimp.gimp-2.10")

    override var appName: String { "GIMP" }
    override var appMarketingName: String { "GIMP" }
    override var description: String { "GIMP is a cross-platform image editor." }

    var arch: String {
        #if arch(arm64)
            return "x86_64"
        #else
            return "arm64"
        #endif
    }

    override var latestURL: URL {
        return URL(string: "https://download.gimp.org/gimp/v2.10/macos/gimp-\(latestVersion)-1-\(arch).dmg")!
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://www.gimp.org/downloads/"
        // https://download.gimp.org/gimp/v2.10/macos/gimp-2.10.32-1-arm64.dmg
        let versionRegex = Regex("GIMP&nbsp;([-\\.\\d]+)<br/>")
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
