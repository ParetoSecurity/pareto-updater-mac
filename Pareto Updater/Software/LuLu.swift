//
//  LuLu.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppLulu: GitHubApp {
    override var appName: String { "LuLu" }
    override var appMarketingName: String { "LuLu" }
    override var appBundle: String { "com.objective-see.lulu.app" }

    static let sharedInstance = AppLulu(
        org: "objective-see", repo: "LuLu"
    )
}
