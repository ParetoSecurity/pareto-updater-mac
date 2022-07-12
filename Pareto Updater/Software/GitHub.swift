//
//  LibreOffice.swift
//  Pareto Updater
//
//  Created by Janez Troha on 11/05/2022.
//

import Alamofire
import AppKit
import Combine
import Foundation
import os.log
import OSLog
import Regex

private struct Release: Codable {
    let version: String

    enum CodingKeys: String, CodingKey {
        case version
    }
}

private typealias Releases = [Release]

class AppGitHub: AppUpdater {
    static let sharedInstance = AppGitHub()

    override var appName: String { "GitHub Desktop" }
    override var appMarketingName: String { "GitHub Desktop" }
    override var appBundle: String { "com.github.GitHubClient" }

    override var latestURL: URL {
        #if arch(arm64)
            return URL(string: "https://central.github.com/deployments/desktop/desktop/latest/darwin")!
        #else
            return URL(string: "https://central.github.com/deployments/desktop/desktop/latest/darwin-arm64")!
        #endif
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = "https://central.github.com/deployments/desktop/desktop/changelog.json"
        os_log("Requesting %{public}s", url)
        AF.request(url).responseDecodable(of: Releases.self, queue: Constants.httpQueue) { response in
            if response.error == nil {
                let versions = response.value?.sorted(by: { lhs, rhs in
                    lhs.version.versionCompare(rhs.version) == .orderedDescending
                })
                completion(versions?.first?.version ?? "0.0.0")
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }
        }
    }
}
