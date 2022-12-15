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

class AppDiscord: AppUpdater {
    static let sharedInstance = AppDiscord(appBundle: "com.hnc.Discord")

    override var appName: String { "Discord" }
    override var appMarketingName: String { "Discord" }
    override var description: String { "Discord is the easiest way to talk over voice, video, and text. Talk, chat, hang out, and stay close with your friends and communities." }
    override var latestURL: URL {
        URL(string: "https://discord.com/api/download?platform=osx")!
    }

    override var latestURLExtension: String {
        "dmg"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://discord.com/api/download?platform=osx"
        let versionRegex = Regex("osx/?([\\.\\d]+)/Discord") // https://dl.discordapp.net/apps/osx/0.0.268/Discord.dmg
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
