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
    override var description: String { "GitUp is a bet to invent a new Git interaction model that lets engineers of all levels work quickly, safely, and without headaches." }
    static let sharedInstance = AppGitUp(
        org: "git-up", repo: "GitUp"
    )
}
