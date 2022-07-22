//
//  PkgApps.swift
//  Pareto Updater
//
//  Created by Janez Troha on 01/07/2022.
//

import Alamofire
import AppUpdater
import Foundation
import os.log
import Path

typealias APIReleases = [Release]

class GitHubApp: AppUpdater {
    private var gitHubOrg: String
    private var gitHubRepo: String

    init(org: String, repo: String) {
        gitHubOrg = org
        gitHubRepo = repo
    }

    private var updateURL: String {
        "https://api.github.com/repos/\(gitHubOrg)/\(gitHubRepo)/releases"
    }

    override var latestURL: URL {
        let url = updateURL
        os_log("Requesting %{public}s", url)
        var update = URL(string: url)!
        let lock = DispatchSemaphore(value: 0)

        AF.request(url).responseDecodable(of: APIReleases.self, queue: Constants.httpQueue, completionHandler: { response in
            if let version = try? response.value?.findViableUpdate(prerelease: false), response.error == nil {
                if let file = version.assets.filter({ asset in
                    asset.name.contains(".dmg") || asset.name.contains(".zip")
                }).first?.browserDownloadURL {
                    update = file
                }
                lock.signal()
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                lock.signal()
            }
        })
        lock.wait()
        return update
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = updateURL
        os_log("Requesting %{public}s", url)
        AF.request(url).responseDecodable(of: APIReleases.self, queue: Constants.httpQueue, completionHandler: { response in
            if let version = try? response.value?.findViableUpdate(prerelease: false), response.error == nil {
                completion(version.version.description)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }
        })
    }
}
