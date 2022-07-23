//
//  KeKa.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppKeKa: SparkleApp {
    static let sharedInstance = AppKeKa(
        name: "KeKa",
        bundle: "com.aone.keka",
        url: "https://u.keka.io"
    )
}
