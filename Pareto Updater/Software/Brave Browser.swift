//
//  Brave Browser.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Version

class AppBraveBrowserUpdater: SparkleApp {
    static let sharedInstance = AppBraveBrowserUpdater(
        name: "Brave Browser",
        bundle: "com.brave.Browser",
        url: "https://updates.bravesoftware.com/sparkle/Brave-Browser/stable/appcast.xml"
    )

    override var UUID: String {
        "64026bd2-54c2-4d3e-8696-559091457dde"
    }
}
