//
//  Macy.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppGitUp: GitHubApp {
    override var appName: String { "GitUp" }
    override var appMarketingName: String { "GitUp" }
    override var appBundle: String { "co.gitup.mac" }

    static let sharedInstance = AppGitUp(
        org: "git-up", repo: "GitUp"
    )
}
