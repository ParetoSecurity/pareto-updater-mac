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
import Path
import Regex

class AppMTeams: PkgApp {
    static let sharedInstance = AppMTeams(pkgName: "Teams_osx_app.pkg", appPkgName: "Microsoft Teams.app")

    override var appName: String { "Microsoft Teams" }
    override var appMarketingName: String { "Microsoft Teams" }
    override var appBundle: String { "com.microsoft.teams" }

    override var latestURL: URL {
        return URL(string: "https://go.microsoft.com/fwlink/?linkid=869428")!
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache("https://macadmins.software/latest.xml")
        let packageRegex = Regex("<package>(.*)</package>")
        let versionRegex = Regex("<cfbundleversion>(\\d+)</cfbundleversion>")

        os_log("Requesting %{public}s", url)
        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                let fallback = "<package><cfbundleidentifier>com.microsoft.teams</cfbundleidentifier><cfbundleversion>435562</cfbundleversion></package>"
                let html = response.value?.removingWhitespaces() ?? fallback
                let app = packageRegex.allMatches(in: html).filter { $0.value.contains(self.appBundle) }.first
                let version = versionRegex.firstMatch(in: app?.value ?? fallback)?.groups.first?.value ?? "135562"
                os_log("%{public}s version=%{public}s", self.appBundle, version)
                completion("1.00.\(version)")
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }
}
