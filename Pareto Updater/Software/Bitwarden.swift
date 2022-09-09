//
//  Bitwarden.swift
//  Pareto Security
//
//  Created by Janez Troha on 11/11/2021.
//
import Alamofire
import Foundation
import os.log

class AppBitwardenUpdater: AppUpdater {
    static let sharedInstance = AppBitwardenUpdater()

    override var appName: String { "Bitwarden" }
    override var appMarketingName: String { "Bitwarden" }
    override var appBundle: String { "com.bitwarden.desktop" }
    override var description: String { "Bitwarden is an integrated open source password management solution for individuals, teams, and business organizations." }
    override var latestURL: URL {
        return URL(string: "https://vault.bitwarden.com/download/?app=desktop&platform=macos&variant=dmg")!
    }

    override var latestURLExtension: String {
        "dmg"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache("https://itunes.apple.com/lookup?bundleId=\(appBundle)&country=us&entity=macSoftware&limit=1")
        os_log("Requesting %{public}s", url)
        AF.request(url).responseDecodable(of: AppStoreResponse.self, queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let version = response.value?.results.first?.version ?? "0.0.0"
                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion(version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }
        })
    }
}
