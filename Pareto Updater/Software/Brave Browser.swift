//
//  Brave Browser.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Foundation

class AppBraveBrowserUpdater: SparkleApp {
    override var description: String { "The Brave browser is a fast, private and secure web browser for PC, Mac and mobile." }
    static let sharedInstance = AppBraveBrowserUpdater(
        name: "Brave Browser",
        bundle: "com.brave.Browser",
        url: "https://updates.bravesoftware.com/sparkle/Brave-Browser/stable/appcast.xml"
    )

    override var latestURL: URL {
        URL(string: "https://referrals.brave.com/latest/Brave-Browser.dmg")!
    }

    override var textVersion: String {
        if isInstalled {
            if let version = Bundle.appVersion(path: applicationPath) {
                let nibbles = version.lowercased().split(separator: ".")
                return String(nibbles[1 ... nibbles.count - 1].joined(separator: "."))
            }
            return "0.0.0"
        }
        return "0.0.0"
    }
}
