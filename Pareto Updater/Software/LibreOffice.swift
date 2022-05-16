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
import Version

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
            return URL(string: "https://download.documentfoundation.org/libreoffice/stable/\(latestVersionCached)/mac/x86_64/LibreOffice_\(latestVersionCached)_MacOS_x86_64.dmg")!
        #endif
    }

    override var currentVersion: Version {
        if applicationPath == nil {
            return Version(0, 0, 0)
        }
        let v = Bundle.appVersion(path: applicationPath ?? "1.2.3.4")?.split(separator: ".")
        return Version(Int(v?[0] ?? "0") ?? 0, Int(v?[1] ?? "0") ?? 0, Int(v?[2] ?? "0") ?? 0)
    }

    func getLatestVersions(completion: @escaping ([String]) -> Void) {
        let url = viaEdgeCache("https://www.libreoffice.org/download/download/")
        os_log("Requesting %{public}s", url)
        let versionRegex = Regex("<span class=\"dl_version_number\">?([\\.\\d]+)</span>")
        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let html = response.value ?? "<span class=\"dl_version_number\">1.2.4</span>"
                let versions = versionRegex.allMatches(in: html).map { $0.groups.first?.value ?? "1.2.4" }
                completion(versions)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion(["0.0.0"])
            }
        })
    }

    public var latestVersions: [Version] {
        var tempVersions = [Version(0, 0, 0)]
        let lock = DispatchSemaphore(value: 0)
        getLatestVersions { versions in
            tempVersions = versions.map { Version($0) ?? Version(0, 0, 0) }
            lock.signal()
        }
        lock.wait()
        return tempVersions
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        if currentVersion.major == latestVersions.first?.major, currentVersion.minor == latestVersions.first?.minor {
            // bugfix for latest
            completion(latestVersions.first?.description ?? "0.0.0")
        } else if currentVersion.major == latestVersions.last?.major, currentVersion.minor == latestVersions.last?.minor {
            // bugfix for LTS
            completion(latestVersions.last?.description ?? "0.0.0")
        } else {
            // very-old version, assume LTS should be used
            completion(latestVersions.last?.description ?? "0.0.0")
        }
    }
}
