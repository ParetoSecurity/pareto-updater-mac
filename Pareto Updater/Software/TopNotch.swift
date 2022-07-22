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

class AppTopNotch: SparkleApp {
    static let sharedInstance = AppTopNotch(
        name: "TopNotch",
        bundle: "pl.maketheweb.TopNotch",
        url: "https://updates.topnotch.app/appcast.xml"
    )
}
