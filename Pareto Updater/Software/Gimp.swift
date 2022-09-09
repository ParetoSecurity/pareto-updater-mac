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
    static let sharedInstance = AppGimp()

    override var appName: String { "GIMP-2.10" }
    override var appMarketingName: String { "GIMP" }
    override var appBundle: String { "org.gimp.gimp-2.10:" }
    override var description: String { "GIMP is a cross-platform image editor." }
    override var latestURL: URL {
        let nibles = latestVersion.split(separator: ".")
        return URL(string: "https://download.gimp.org/gimp/v\(nibles[0]).\(nibles[1])/osx/gimp-\(latestVersion)-x86_64.dmg")!
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://www.gimp.org/downloads/"
        let versionRegex = Regex("osx/gimp-?([\\.\\d]+)-x86_64.dmg")
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
