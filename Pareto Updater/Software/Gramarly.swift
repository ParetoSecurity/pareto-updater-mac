//
//  Grammarly.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Foundation

class AppGrammarly: SparkleApp {
    override var description: String { "With comprehensive feedback on spelling, grammar, punctuation, clarity, and writing style, Grammarly is more than just a proofreader." }
    static let sharedInstance = AppGrammarly(
        name: "Grammarly Desktop",
        bundle: "com.grammarly.ProjectLlama",
        url: "https://download-mac.grammarly.com/appcast.xml"
    )
}
