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
    private var sparkBundle: String
    private var updateURL: String
    private var uuid: String

    init(name: String, bundle: String, url: String) {
        sparkName = name
        sparkBundle = bundle
        updateURL = url
        uuid = Foundation.UUID().uuidString
    }

    override var appName: String { sparkName }
    override var appMarketingName: String { sparkName }
    override var appBundle: String { sparkBundle }

    override var UUID: String {
        uuid
    }

    override var latestURL: URL {
        let url = viaEdgeCache(updateURL)
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
                lock.signal()
            } else {
                os_log("%{public}s failed: %{public}s", self.appBundle, response.error.debugDescription)
                lock.signal()
            }

        })
        lock.wait()
        return update
    }

    func nibbles(version: String, sep: Character = ".") -> Int {
        var total = 0
        var round = 0
        let levels = version.split(separator: sep).reversed()
        for level in levels {
            if level.contains("-") {
                total = nibbles(version: String(level), sep: "-")
            }
            total = (Int(level) ?? 1) * Int(2 << round)
            round += 1
        }
        return total
    }

    override var hasUpdate: Bool {
        nibbles(version: latestVersionCached) > nibbles(version: textVersion)
    }

    override func getLatestVersion(completion: @escaping (String) -> Void) {
        let url = viaEdgeCache(updateURL)
        os_log("Requesting %{public}s", url)
        AF.request(url).responseString(queue: Constants.httpQueue, completionHandler: { response in
            if response.error == nil {
                guard let xml = response.data else {
                    completion("0.0.0")
                    return
                }
                let app = AppCast(data: xml)
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
            if plist?["SUFeedURL"] != nil {
                let appBundle = plist?["CFBundleName"] as! String
                let appName = plist?["CFBundleName"] as! String
                let url = plist?["SUFeedURL"] as! String
                os_log("%{public}s URL: %{public}s", appBundle, url)
                if !url.isEmpty {
                    detectedApps.append(SparkleApp(name: appName, bundle: appBundle, url: url))
                }
            }
        }
        return detectedApps.sorted(by: { lha, rha in
            lha.appMarketingName < rha.appMarketingName
        })
    }
}
