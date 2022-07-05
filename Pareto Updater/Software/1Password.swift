//
//  1Password7.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Alamofire
import Foundation
import os.log
import Regex

class App1Password8AppUpdater: AppUpdater {
    static let sharedInstance = App1Password8AppUpdater()

    override var appName: String { "1Password" }
    override var appMarketingName: String { "1Password" }
    override var appBundle: String { "com.1password.1password" }

    override var UUID: String {
        "541f82b2-db88-588f-9389-a41b81973b45"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache("https://releases.1password.com/mac/")
        let versionRegex = Regex("Updated to ([\\.\\d]+) on")
        os_log("Requesting %{public}s", url)
        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let html = response.value ?? "Updated to 1.8.0 on"
                let versions = versionRegex.allMatches(in: html).map { $0.groups.first!.value }
                let version = versions.sorted(by: { $0.lowercased() < $1.lowercased() }).last ?? "1.8.0"
                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion(version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }

    override var latestURL: URL {
        #if arch(arm64)
            return URL(string: "https://downloads.1password.com/mac/1Password-latest-aarch64.zip")!
        #else
            return URL(string: "https://downloads.1password.com/mac/1Password-latest-x86_64.zip")!
        #endif
    }
}
