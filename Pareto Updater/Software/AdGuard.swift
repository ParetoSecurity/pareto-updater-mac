//
//  AdGuard.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppAdGuard: GitHubApp {
    override var appName: String { "AdGuard" }
    override var appMarketingName: String { "AdGuard" }
    override var description: String { "AdGuard for Mac is the world's first standalone adblock app designed specifically for macOS." }
    static let sharedInstance = AppAdGuard(
        appBundle: "com.adguard.mac.adguard", org: "objective-see", repo: "AdguardForMac"
    )
}
