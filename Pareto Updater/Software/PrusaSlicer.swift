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
    override var description: String { "G-code generator for 3D printers (RepRap, Makerbot, Ultimaker etc.)" }
    static let sharedInstance = AppPrusaSlicer(
        appBundle: "com.prusa3d.slic3r", org: "prusa3d", repo: "PrusaSlicer"
    )

    override var hasUpdate: Bool {
        // it's a mess
        if latestVersion.contains(textVersion) {
            return false
        }
        return true
    }

    override public func latestVersionHook(_ version: String) -> String {
        return version.replacingOccurrences(of: "ersion_", with: "")
    }

    override public func currentVersionHook(_ version: String) -> String {
        let versionRegex = Regex("slicer-(.+)\\+")
        if let parsed = versionRegex.firstMatch(in: version)?.groups.first?.value {
            return parsed
        }
        return version
    }
}
