//
//  Viber.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Alamofire
import Foundation
import os.log
import Regex

class AppViber: AppUpdater {
    static let sharedInstance = AppViber()

    override var appName: String { "Viber" }
    override var appMarketingName: String { "Viber" }
    override var appBundle: String { "com.viber.osx" }

    override var latestURL: URL {
        URL(string: "https://download.cdn.viber.com/desktop/mac/Viber.dmg")!
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        completion("18.4.0")
    }
}
