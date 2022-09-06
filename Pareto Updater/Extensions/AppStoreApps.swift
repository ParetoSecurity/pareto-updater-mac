//
//  SparkleApps.swift
//  Pareto Updater
//
//  Created by Janez Troha on 01/07/2022.
//

import Alamofire
import Foundation
import os.log
import Regex
import SwiftUI

class AppStoreApp: AppUpdater {
    private var lName: String
    private var lBundle: String
    private var lLocation: URL

    init(name: String, bundle: String, location: URL) {
        lName = name
        lBundle = bundle
        lLocation = location
    }

    override var appName: String { lName }
    override var appMarketingName: String { lName }
    override var appBundle: String { lBundle }

    override var hasUpdate: Bool {
        latestVersion.versionCompare(textVersion) == .orderedDescending
    }

    override func updateApp(completion: @escaping (AppUpdaterStatus) -> Void) {
        let attributes = NSMetadataItem(url: lLocation)
        if let id = attributes?.value(forAttribute: "kMDItemAppStoreAdamID") as? Int {
            NSWorkspace.shared.open(URL(string: "itms-apps://apple.com/app/id\(id)")!)
        }
        completion(.Unsupported)
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let languageCode = Locale.current.regionCode ?? "US"
        var url = URLComponents(url: URL(string: "https://itunes.apple.com/lookup")!, resolvingAgainstBaseURL: false)
        url?.queryItems = [
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "entity", value: "desktopSoftware"),
            URLQueryItem(name: "country", value: languageCode),
            URLQueryItem(name: "bundleId", value: appBundle)
        ]
        if let request = url?.url {
            os_log("Requesting %{public}s", request.debugDescription)
            AF.request(viaEdgeCache(request.description)).responseDecodable(of: AppStoreResponse.self, queue: Constants.httpQueue, completionHandler: { response in
                if let version = response.value?.results.first, response.error == nil {
                    completion(version.version)
                } else {
                    os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                    completion("0.0.0")
                }
            })
        }
        completion("0.0.0")
    }

    static var all: [AppUpdater] {
        var detectedApps: [AppUpdater] = []
        let allApps = try! FileManager.default.contentsOfDirectory(at: URL(string: "/Applications")!, includingPropertiesForKeys: [.isApplicationKey])
        for app in allApps {
            let attributes = NSMetadataItem(url: app)
            if !(attributes?.value(forAttribute: "kMDItemAppStoreHasReceipt") as? Bool ?? false) {
                continue
            }
            let plist = AppBundles.readPlistFile(fileURL: app.appendingPathComponent("Contents/Info.plist"))
            if let appName = plist?["CFBundleName"] as? String,
               let appBundle = plist?["CFBundleIdentifier"] as? String {
                let bundleApp = AppStoreApp(
                    name: appName,
                    bundle: appBundle,
                    location: app
                )
                detectedApps.append(bundleApp)
            }
        }
        return detectedApps
    }
}
