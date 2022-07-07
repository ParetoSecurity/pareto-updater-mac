//
//  Signal.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppSpyBuster: SparkleApp {
    static let sharedInstance = AppSpyBuster(
        name: "SpyBuster",
        bundle: "com.macpaw-labs.snitch",
        url: "https://updates.devmate.com/com.macpaw-labs.snitch.xml"
    )
}
