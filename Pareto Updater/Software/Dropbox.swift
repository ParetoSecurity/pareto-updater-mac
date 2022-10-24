//
//  AppDiscord.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppDropbox: AppUpdater {
    static let sharedInstance = AppDropbox()

    override var appName: String { "Dropbox" }
    override var appMarketingName: String { "Dropbox" }
    override var appBundle: String { "com.getdropbox.dropbox" }
    override var description: String { "Save and access your files from any device, and share." }
    override var latestURL: URL {
        URL(string: "https://www.dropbox.com/downloading?plat=mac&full=1")!
    }

    override var latestURLExtension: String {
        "dmg"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://www.dropbox.com/download?plat=mac&full=1"
        let versionRegex = Regex("%20?([\\.\\d]+)\\.dmg") // https://edge.dropboxstatic.com/dbx-releng/client/Dropbox%20159.4.5870.dmg
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
