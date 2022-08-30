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
    override var appBundle: String { "com.adguard.mac.adguard" }

    static let sharedInstance = AppAdGuard(
        org: "objective-see", repo: "AdguardForMac"
    )
}
