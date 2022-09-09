//
//  WorkHours.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppWorkHours: GitHubApp {
    override var appName: String { "Work Hours" }
    override var appMarketingName: String { "Work Hours" }
    override var appBundle: String { "co.niteo.work-hours.Work-Hours" }
    override var description: String { "" }
    static let sharedInstance = AppWorkHours(
        org: "teamniteo", repo: "work-hours-mac"
    )
}
