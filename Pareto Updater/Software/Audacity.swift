//
//  Audacity.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppAudacity: GitHubApp {
    override var appName: String { "Audacity" }
    override var appMarketingName: String { "Audacity" }
    override var appBundle: String { "org.audacityteam.audacity" }
    override var description: String { "Audacity is an easy-to-use, multi-track audio editor and recorder." }
    static let sharedInstance = AppAudacity(
        org: "audacity", repo: "audacity"
    )

    override public func latestVersionHook(_ version: String) -> String {
        return version.replacingOccurrences(of: "audacity-", with: "")
    }

    override public func currentVersionHook(_ version: String) -> String {
        let versionRegex = Regex("audacity-(.+)\\+")
        if let parsed = versionRegex.firstMatch(in: version)?.groups.first?.value {
            return parsed
        }
        return version
    }
}
