//
//  HiddenBar.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppCryptomator: GitHubApp {
    override var appName: String { "Cryptomator" }
    override var appMarketingName: String { "Cryptomator" }
    override var appBundle: String { "org.cryptomator" }

    static let sharedInstance = AppCryptomator(
        org: "cryptomator", repo: "cryptomator"
    )

    override var latestURL: URL {
        #if arch(arm64)
            return URL(string: "https://github.com/cryptomator/cryptomator/releases/download/\(latestVersion)/Cryptomator-\(latestVersion)-arm64.dmg")!
        #else
            return URL(string: "https://github.com/cryptomator/cryptomator/releases/download/\(latestVersion)/Cryptomator-\(latestVersion).dmg")!
        #endif
    }
}
