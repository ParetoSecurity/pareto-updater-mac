//
//  Rectangle.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppRectangle: SparkleApp {
    override var description: String { "Move and resize windows in macOS using keyboard shortcuts or snap areas. " }
    static let sharedInstance = AppRectangle(
        name: "Rectangle",
        bundle: "com.knollsoft.Rectangle",
        url: "https://rectangleapp.com/downloads/updates.xml"
    )
}
