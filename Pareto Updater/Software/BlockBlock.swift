//
//  BlockBlock.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppBlockBlock: GitHubApp {
    override var appName: String { "BlockBlock" }
    override var appMarketingName: String { "BlockBlock" }
    override var appBundle: String { "com.objective-see.blockblock.installer" }

    static let sharedInstance = AppBlockBlock(
        org: "objective-see", repo: "BlockBlock"
    )
}
