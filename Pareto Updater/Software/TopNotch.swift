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
    override var description: String { "TopNotch is a little macOS app that makes your menu bar black and hides the notch." }
    static let sharedInstance = AppTopNotch(
        name: "Top Notch",
        bundle: "pl.maketheweb.TopNotch",
        url: "https://updates.topnotch.app/appcast.xml"
    )
}
