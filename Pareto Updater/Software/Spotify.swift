//
//  Slack.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Alamofire
import Foundation
import os.log
import Regex

class AppSpotify: AppUpdater {
    static let sharedInstance = AppSpotify()

    override var appName: String { "Spotify" }
    override var appMarketingName: String { "Spotify" }
    override var appBundle: String { "com.spotify.client" }
    override var description: String { "Spotify is a digital music player that gives you access to millions of songs." }
    override var latestURL: URL {
        #if arch(arm64)
            return URL(string: "https://download.scdn.co/SpotifyARM64.dmg")!
        #else
            return URL(string: "https://download.scdn.co/Spotify.dmg")!
        #endif
    }

    override var textVersion: String {
        if isInstalled {
            return (Bundle.appVersion(path: applicationPath) ?? "0.0.0").lowercased().split(separator: ".")[0 ... 3].joined(separator: ".")
        }
        return "0.0.0"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        completion("1.1.93.896")
    }
}
