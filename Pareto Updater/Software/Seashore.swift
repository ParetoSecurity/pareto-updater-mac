//
//  Seashore.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppSeashore: GitHubApp {
    override var appName: String { "Seashore" }
    override var appMarketingName: String { "Seashore" }
    override var appBundle: String { "app.seashore" }

    static let sharedInstance = AppSeashore(
        org: "robaho", repo: "Seashore"
    )
}
