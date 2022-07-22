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

class AppHiddenBar: GitHubApp {
    override var appName: String { "Hidden Bar" }
    override var appMarketingName: String { "Hidden Bar" }
    override var appBundle: String { "com.dwarvesv.minimalbar" }

    static let sharedInstance = AppHiddenBar(
        org: "dwarvesf", repo: "hidden"
    )
}
