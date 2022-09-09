//
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Foundation

class AppITerm: SparkleApp {
    override var description: String { "iTerm2 is a replacement for Terminal and the successor to iTerm." }
    static let sharedInstance = AppITerm(
        name: "iTerm",
        bundle: "com.googlecode.iterm2",
        url: "https://iterm2.com/appcasts/final_modern.xml"
    )
}
