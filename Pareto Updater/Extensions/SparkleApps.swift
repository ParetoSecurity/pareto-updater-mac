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

class SparkleApp: AppUpdater {
    private var sparkName: String
    private var updateURL: String

    init(name: String, bundle: String, url: String) {
        sparkName = name
        updateURL = url
        super.init(appBundle: bundle)
    }

    override var appName: String { sparkName }
    override var appMarketingName: String { sparkName }

    override var latestURL: URL {
        let url = updateURL
        os_log("Requesting %{public}s", url)
        var update = URL(string: url)!
        let lock = DispatchSemaphore(value: 0)
        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                guard let xml = response.data else {
                    lock.signal()
                    return
                }
                let app = AppCast(data: xml)
                update = URL(string: app.url) ?? update
                os_log("%{public}s latest bundle: %{public}s", self.appBundle, response.error.debugDescription)
                lock.signal()
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                lock.signal()
            }

        })
        lock.wait()
        return update
    }

    override var hasUpdate: Bool {
        // normal check
        var update = false

        if super.hasUpdate {
            update = true
        }
        // for weird versions
        // v12.2.2 or 12.2.2(1234)
        if latestVersion.contains(textVersion) {
            update = false
        }
        return update
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = updateURL
        os_log("Requesting %{public}s", url)
        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                guard let xml = response.data else {
                    completion("0.0.0")
                    return
                }
                let app = AppCast(data: xml)
                os_log("%{public}s version: %{public}s", self.appBundle, app.version)
                completion(app.version)
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                completion("0.0.0")
            }

        })
    }

    static var all: [AppUpdater] {
        var detectedApps: [AppUpdater] = []
        let allApps = try! FileManager.default.contentsOfDirectory(at: URL(string: "/Applications")!, includingPropertiesForKeys: [.isApplicationKey])
        for app in allApps {
            let plist = AppBundles.readPlistFile(fileURL: app.appendingPathComponent("Contents/Info.plist"))
            if let url = plist?["SUFeedURL"] as? String,
               let appName = plist?["CFBundleName"] as? String,
               let appBundle = plist?["CFBundleIdentifier"] as? String {
                if !Constants.unsupportedBundles.contains(appBundle),
                   !AppBundles.bundledApps.map({ b in
                       b.appBundle.lowercased()
                   }).contains(appBundle.lowercased()),
                   url.contains("https://") {
                    let bundleApp = SparkleApp(
                        name: appName,
                        bundle: appBundle,
                        url: url
                    )
                    detectedApps.append(bundleApp)
                }
            }
        }
        return detectedApps.sorted(by: { lha, rha in
            lha.appMarketingName < rha.appMarketingName
        })
    }
}
