//
//  SwiftBar.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppSwiftBar: SparkleApp {
    static let sharedInstance = AppSwiftBar(
        name: "SwiftBar",
        bundle: "com.ameba.SwiftBar",
        url: "https://swiftbar.github.io/SwiftBar/appcast.xml"
    )
}
