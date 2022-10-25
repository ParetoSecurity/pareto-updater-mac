//
//  Brave Browser.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Foundation

class AppDuckDuckGo: SparkleApp {
    override var description: String { "The DuckDuckGo browser provides the most comprehensive online privacy protection with the push of a button." }
    static let sharedInstance = AppDuckDuckGo(
        name: "DuckDuckGo",
        bundle: "com.duckduckgo.macos.browser",
        url: "https://staticcdn.duckduckgo.com/macos-desktop-browser/appcast.xml"
    )

    override var latestURL: URL {
        URL(string: "https://staticcdn.duckduckgo.com/macos-desktop-browser/duckduckgo.dmg")!
    }
}
