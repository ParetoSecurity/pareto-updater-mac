//
//  Brave Browser.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Foundation

class AppBraveBrowserUpdater: SparkleApp {
    static let sharedInstance = AppBraveBrowserUpdater(
        name: "Brave Browser",
        bundle: "com.brave.Browser",
        url: "https://updates.bravesoftware.com/sparkle/Brave-Browser/stable/appcast.xml"
    )

    override var latestURL: URL {
        URL(string: "https://referrals.brave.com/latest/Brave-Browser.dmg")!
    }

    override var textVersion: String {
        if let path = applicationPath {
            if let version = Bundle.appVersion(path: path) {
                let nibbles = version.lowercased().split(separator: ".")
                return String(nibbles[1 ... nibbles.count - 1].joined(separator: "."))
            }
            return "0.0.0"
        }
        return "0.0.0"
    }
}
