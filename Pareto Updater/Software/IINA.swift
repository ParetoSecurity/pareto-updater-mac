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

class AppIINA: SparkleApp {
    override var description: String { "IINA is the modern video player for macOS." }
    static let sharedInstance = AppIINA(
        name: "IINA",
        bundle: "com.colliderli.iina",
        url: "https://www.iina.io/appcast.xml"
    )
}
