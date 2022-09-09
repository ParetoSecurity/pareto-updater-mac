//
//  Slack.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Alamofire
import Foundation
import os.log
import Regex

class AppCyberduck: SparkleApp {
    override var description: String { "Cyberduck is a cloud storage browser." }
    static let sharedInstance = AppCyberduck(
        name: "Cyberduck",
        bundle: "ch.sudo.cyberduck",
        url: "https://version.cyberduck.io//changelog.rss"
    )
}
