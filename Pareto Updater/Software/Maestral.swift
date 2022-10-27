//
//  Maestral.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Foundation

class AppMaestral: SparkleApp {
    override var description: String { "A light-weight and open-source Dropbox client for macOS and Linux." }
    static let sharedInstance = AppMaestral(
        name: "Maestral",
        bundle: "com.samschott.maestral",
        url: "https://maestral.app/appcast.xml"
    )
}
