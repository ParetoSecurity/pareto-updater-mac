//
//  IINA.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppMacy: SparkleApp {
    static let sharedInstance = AppMacy(
        name: "Macy",
        bundle: "org.p0deje.Maccy",
        url: "https://raw.githubusercontent.com/p0deje/Maccy/master/appcast.xml"
    )
}
