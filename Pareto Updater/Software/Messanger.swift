//
//  Brave Browser.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Foundation

class AppMessenger: SparkleApp {
    override var description: String { "Hang out anytime, anywhere. Facebook Messenger makes it easy and fun to stay close to your favorite people." }
    static let sharedInstance = AppMessenger(
        name: "Messenger",
        bundle: "com.facebook.archon.developerID",
        url: "https://www.facebook.com/messenger/desktop/zeratul/update.xml?target=zeratul&platform=mac"
    )
    override var latestURLExtension: String {
        "dmg"
    }
}
