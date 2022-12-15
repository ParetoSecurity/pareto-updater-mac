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
    override var description: String { "" }
    static let sharedInstance = AppSeashore(
        appBundle: "app.seashore", org: "robaho", repo: "Seashore"
    )
}
