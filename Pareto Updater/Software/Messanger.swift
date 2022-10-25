//
//  Brave Browser.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Foundation

class AppMessenger: SparkleApp {
    override var description: String { "The DuckDuckGo browser provides the most comprehensive online privacy protection with the push of a button." }
    static let sharedInstance = AppMessenger(
        name: "Messenger",
        bundle: "com.facebook.archon.developerID",
        url: "https://www.facebook.com/messenger/desktop/zeratul/update.xml?target=zeratul&platform=mac"
    )
    override var latestURLExtension: String {
        "dmg"
    }
}
