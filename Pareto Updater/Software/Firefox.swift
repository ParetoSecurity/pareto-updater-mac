//
//  Firefox.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Alamofire
import AppKit
import Combine
import Foundation
import os.log
import OSLog
import Version

private typealias FirefoxVersions = [String: String]

class AppFirefox: AppUpdater {
    static let sharedInstance = AppFirefox()

    override var appName: String { "Firefox" }
    override var appMarketingName: String { "Firefox" }
    override var appBundle: String { "org.mozilla.firefox" }

    override var UUID: String {
        "768a574c-75a2-536d-8785-ef9512981184"
    }

    private func normalizedVersion(_ version: String) -> Version {
        let v = version.split(separator: ".")
        if v.count == 2 {
            return Version(Int(v[0]) ?? 0, Int(v[1]) ?? 0, 0)
        }
        return Version(Int(v[0]) ?? 0, Int(v[1]) ?? 0, Int(v[2]) ?? 0)
    }

    override var currentVersion: Version {
        if applicationPath == nil {
            return Version(0, 0, 0)
        }
        return normalizedVersion(appVersion(path: applicationPath!)!)
    }

    override var latestURL: URL {
        let lock = DispatchSemaphore(value: 0)
        var dmg = URL(string: "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US")!
        AF.request(dmg.absoluteString, method: .head).redirect(using: Redirector(behavior: .doNotFollow)).response(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let location = response.response?.allHeaderFields["Location"] as? String ?? dmg.absoluteString
                dmg = URL(string: location)!
            }
            lock.signal()
        })
        lock.wait()
        return dmg
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache("https://product-details.mozilla.org/1.0/firefox_history_major_releases.json")
        os_log("Requesting %{public}s", url)
        AF.request(url).responseDecodable(of: FirefoxVersions.self, queue: Constants.httpQueue) { response in
            if response.error == nil {
                let version = response.value?.keys.sorted(by: { lhs, rhs in
                    self.normalizedVersion(rhs) < self.normalizedVersion(lhs)
                }).first ?? "0.0.0"

                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion(self.normalizedVersion(version).description)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }
        }
    }
}
