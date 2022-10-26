//
//  GoogleChrome.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Alamofire
import AppKit
import Combine
import Foundation
import os.log
import OSLog

// MARK: - GoogleResponse

private struct GoogleResponse: Codable {
    let versions: [ChromeVersion]
    let nextPageToken: String
}

// MARK: - Version

private struct ChromeVersion: Codable {
    let name, version: String
}

class AppGoogleChrome: PkgApp {
    static let sharedInstance = AppGoogleChrome(pkgName: "GoogleChrome.pkg", appPkgName: "Google Chrome.appGoogleChrome.pkg")

    override var appName: String { "Google Chrome" }
    override var appMarketingName: String { "Google Chrome" }
    override var appBundle: String { "com.google.Chrome" }
    override var description: String { "Google Chrome is a web browser developed by Google." }
    override var latestURL: URL {
        return URL(string: "https://dl.google.com/chrome/mac/stable/accept_tos%3Dhttps%253A%252F%252Fwww.google.com%252Fintl%252Fen_ph%252Fchrome%252Fterms%252F%26_and_accept_tos%3Dhttps%253A%252F%252Fpolicies.google.com%252Fterms/googlechrome.pkg")!
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://omahaproxy.appspot.com/history"
        os_log("Requesting %{public}s", url)
        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let csv = response.value ?? "0,0,0.0.0"
                let version = String(csv.split(whereSeparator: \.isNewline).filter { line in
                    line.starts(with: "mac,stable,")
                }.first ?? "0,0,0.0.0").components(separatedBy: ",")[2].split(separator: ".")
                completion(String(version[0 ... version.count - 2].joined(separator: ".")))
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }

    override var textVersion: String {
        if isInstalled {
            if let version = Bundle.appVersion(path: applicationPath) {
                let nibbles = version.lowercased().split(separator: ".")
                return String(nibbles[0 ... nibbles.count - 2].joined(separator: "."))
            }
            return "0.0.0"
        }
        return "0.0.0"
    }
}
