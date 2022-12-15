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

class AppVLC: AppUpdater {
    static let sharedInstance = AppVLC(appBundle: "org.videolan.vlc")

    override var appName: String { "VLC" }
    override var appMarketingName: String { "VLC media player" }
    override var description: String { "VLC is a free and open source cross-platform multimedia player." }
    override var latestURL: URL {
        #if arch(arm64)
            // https://get.videolan.org/vlc/3.0.17.3/macosx/vlc-3.0.17.3-arm64.dmg
            return URL(string: "https://get.videolan.org/vlc/\(latestVersion)/macosx/vlc-\(latestVersion)-arm64.dmg")!
        #else
            // https://get.videolan.org/vlc/3.0.17.3/macosx/vlc-3.0.17.3-intel64.dmg
            return URL(string: "https://get.videolan.org/vlc/\(latestVersion)/macosx/vlc-\(latestVersion)-intel64.dmg")!
        #endif
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache("https://www.videolan.org/vlc/")
        os_log("Requesting %{public}s", url)
        let versionRegex = Regex("vlc/?([\\.\\d]+)/macosx/")
        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if let data = response.value {
                let result = versionRegex.firstMatch(in: data)
                completion(result?.groups.first?.value ?? "0.0.0")
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }
        })
    }
}
