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

class AppLibreOffice: AppUpdater {
    static let sharedInstance = AppLibreOffice()

    override var appName: String { "LibreOffice" }
    override var appMarketingName: String { "LibreOffice" }
    override var appBundle: String { "org.libreoffice.script" }

    override var UUID: String {
        "5726931a-264a-5758-b7dd-d09285ac4b7f"
    }

    override var latestURL: URL {
        #if arch(arm64)
            // https://download.documentfoundation.org/libreoffice/stable/7.2.7/mac/aarch64/LibreOffice_7.2.7_MacOS_aarch64.dmg
            return URL(string: "https://download.documentfoundation.org/libreoffice/stable/\(latestVersionCached)/mac/aarch64/LibreOffice_\(latestVersionCached)_MacOS_aarch64.dmg")!
        #else
            // https://download.documentfoundation.org/libreoffice/stable/7.2.7/mac/x86_64/LibreOffice_7.2.7_MacOS_x86-64.dmg
            return URL(string: "https://download.documentfoundation.org/libreoffice/stable/\(latestVersionCached)/mac/x86_64/LibreOffice_\(latestVersionCached)_MacOS_x86-64.dmg")!
        #endif
    }

    override var textVersion: String {
        if let path = applicationPath {
            if let version = Bundle.appVersion(path: path) {
                return String(version.lowercased().split(separator: ".")[0 ... 2].joined(separator: "."))
            }
            return "0.0.0"
        }
        return "0.0.0"
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache("https://www.libreoffice.org/download/download/")
        os_log("Requesting %{public}s", url)
        let versionRegex = Regex("<span class=\"dl_version_number\">?([\\.\\d]+)</span>")
        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let html = response.value ?? "<span class=\"dl_version_number\">1.2.4</span>"
                let versions = versionRegex.allMatches(in: html).map { $0.groups.first?.value ?? "1.2.4" }
                completion(versions.last ?? "7.2.7")
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }
        })
    }
}
