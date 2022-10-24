//
//  Brave Browser.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Foundation

class AppDuckDuckGo: SparkleApp {
    override var description: String { "The DuckDuckGo browser provides the most comprehensive online privacy protection with the push of a button." }
    static let sharedInstance = AppBraveBrowserUpdater(
        name: "DuckDuckGo",
        bundle: "com.duckduckgo.macos.browser",
        url: "https://staticcdn.duckduckgo.com/macos-desktop-browser/appcast.xml"
    )

    override var latestURL: URL {
        URL(string: "https://staticcdn.duckduckgo.com/macos-desktop-browser/duckduckgo.dmg")!
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
