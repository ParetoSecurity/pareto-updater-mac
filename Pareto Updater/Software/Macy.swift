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

class AppMacy: GitHubApp {
    override var appName: String { "Maccy" }
    override var appMarketingName: String { "Maccy" }
    override var appBundle: String { "org.p0deje.Maccy" }

    static let sharedInstance = AppMacy(
        org: "p0deje", repo: "Maccy"
    )
}
