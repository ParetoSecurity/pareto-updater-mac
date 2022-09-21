//
//  HandBrake.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Alamofire
import Foundation
import os.log
import OSLog
import Regex

class AppHandBrake: SparkleApp {
    override var description: String { "HandBrake is a tool for converting video from nearly any format to a selection of modern, widely supported codecs." }
    static let sharedInstance = AppHandBrake(
        name: "HandBrake",
        bundle: "fr.handbrake.HandBrake",
        url: "https://handbrake.fr/appcast.arm64.xml"
    )
    
    override var latestURLExtension: String {
        "dmg"
    }
}
