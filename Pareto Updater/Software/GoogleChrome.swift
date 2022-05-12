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
import Version

// MARK: - GoogleResponse

private struct GoogleResponse: Codable {
    let versions: [ChromeVersion]
    let nextPageToken: String
}

// MARK: - Version

private struct ChromeVersion: Codable {
    let name, version: String
}

class AppGoogleChrome: AppUpdater {
    static let sharedInstance = AppGoogleChrome()

    override var appName: String { "Google Chrome" }
    override var appMarketingName: String { "Google Chrome" }
    override var appBundle: String { "com.google.Chrome" }

    override var UUID: String {
        "d34ee340-67a7-5e3e-be8b-aef4e3133de0"
    }

    override var latestURL: URL {
        return URL(string: "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg")!
    }

    // Special treatment follows
    // Use build number as definite version comparator
    // https://www.chromium.org/developers/version-numbers
    override var currentVersion: Version {
        if applicationPath == nil {
            return Version(0, 0, 0)
        }
        let v = Bundle.appVersion(path: applicationPath ?? "1.2.3.4")!.split(separator: ".")
        return Version(Int(v[0]) ?? 0, Int(v[1]) ?? 0, Int(v[2]) ?? 0)
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache("https://versionhistory.googleapis.com/v1/chrome/platforms/mac/channels/stable/versions")
        os_log("Requesting %{public}s", url)
        AF.request(url).responseDecodable(of: GoogleResponse.self, queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let v = response.value?.versions.first?.version.split(separator: ".") ?? ["0", "0", "0"]
                completion("\(v[0]).\(v[1]).\(v[2])")
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }
        })
    }
}
