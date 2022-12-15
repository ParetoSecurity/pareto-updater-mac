//
//  AppInkscape.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppInkscape: AppUpdater {
    static let sharedInstance = AppInkscape(appBundle: "org.inkscape.Inkscape")

    override var appName: String { "Inkscape" }
    override var appMarketingName: String { "Inkscape" }
    override var description: String { "Inkscape is professional quality vector graphics software." }
    override var latestURL: URL {
        #if arch(arm64)
            return URL(string: "https://inkscape.org/gallery/item/34664/Inkscape-1.2.1_arm64.dmg")!
        #else
            return URL(string: "https://inkscape.org/gallery/item/34663/Inkscape-1.2.1_x86_64.dmg")!
        #endif
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        completion("1.2.1")
    }
}
