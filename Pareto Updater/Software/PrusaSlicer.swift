//
//  PrusaSlicer.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppPrusaSlicer: GitHubApp {
    override var appName: String { "PrusaSlicer" }
    override var appMarketingName: String { "PrusaSlicer" }
    override var appBundle: String { "com.prusa3d.slic3r" }

    static let sharedInstance = AppPrusaSlicer(
        org: "prusa3d", repo: "PrusaSlicer"
    )
}
