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
    static let sharedInstance = AppViber(appBundle: "com.viber.osx")

    override var appName: String { "Viber" }
    override var appMarketingName: String { "Viber" }
    override var description: String { "Free and secure calls and messages to anyone, anywhere." }
    override var latestURL: URL {
        URL(string: "https://download.cdn.viber.com/desktop/mac/Viber.dmg")!
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        completion("18.4.0")
    }
}
