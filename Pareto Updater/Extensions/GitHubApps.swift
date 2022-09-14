//
//  PkgApps.swift
//  Pareto Updater
//
//  Created by Janez Troha on 01/07/2022.
//

import Alamofire
import Foundation
import os.log
import Path

private struct GHRelease: Decodable {
    public let tagName: String
    public let prerelease: Bool
    public let assets: [Asset]
    public let body: String
    public let createdAt, publishedAt: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case createdAt = "created_at"
        case publishedAt = "published_at"
        case prerelease, assets, body
    }

    public var version: String {
        return tagName
            .lowercased()
            .removingWhitespaces()
            .replacingOccurrences(of: "v", with: "")
    }

    public struct Asset: Decodable {
        public let name: String
        public let size: Int
        public let browserDownloadURL: URL

        enum CodingKeys: String, CodingKey {
            case name
            case size
            case browserDownloadURL = "browser_download_url"
        }
    }
}

private typealias APIReleases = [GHRelease]

private extension APIReleases {
    var latest: GHRelease? {
        filter { r in
            r.version.contains(".") && !r.version.contains("alpha") && !r.version.contains("beta") && !r.version.contains("test")
        }.sorted { lr, rr in
            lr.createdAt > rr.createdAt
        }.first
    }
}

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
            if let version = response.value?.latest, response.error == nil {
                if let file = version.assets.filter({ asset in
                    asset.name.contains(".dmg") || asset.name.contains(".zip") && !(
                        asset.name.contains("win32") || asset.name.contains("win64") || asset.name.contains("linux")
                    )
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
            if let version = response.value?.latest, response.error == nil {
                completion(version.version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }
        })
    }
}
