//
//  Apps.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Foundation
import os.log
import Sentry

protocol AppBundle {
    var apps: [AppUpdater] { get }
    var updating: Bool { get set }
    var installing: Bool { get set }
}

class AppBundles: AppBundle, ObservableObject {
    static let bundledApps = [
        App1Password8AppUpdater.sharedInstance,
        AppBraveBrowserUpdater.sharedInstance,
        AppBitwardenUpdater.sharedInstance,
        AppVSCodeApp.sharedInstance,
        AppSpotify.sharedInstance,
        AppSignal.sharedInstance,
        AppFirefox.sharedInstance,
        AppGoogleChrome.sharedInstance,
        AppSublimeText.sharedInstance,
        AppSlack.sharedInstance,
        AppDocker.sharedInstance,
        AppLibreOffice.sharedInstance,
        AppSpyBuster.sharedInstance,
        AppTopNotch.sharedInstance,
        AppVLC.sharedInstance,
        AppGitHub.sharedInstance
    ].sorted(by: { lha, rha in
        lha.appMarketingName < rha.appMarketingName
    })

    @Published var apps: [AppUpdater]

    @Published var updating: Bool = false
    @Published var installing: Bool = false

    public var haveUpdatableApps: Bool {
        !updatableApps.isEmpty
    }

    public var updatableApps: [AppUpdater] {
        apps.filter { app in
            app.isInstalled && app.usedRecently && app.hasUpdate
        }
    }

    public var installingApps: Bool {
        apps.allSatisfy { app in
            app.status != .Idle
        }
    }

    public var installedApps: [AppUpdater] {
        apps.filter { app in
            app.isInstalled
        }
    }

    func updateApp(withApp: AppUpdater) {
        DispatchQueue.main.async {
            self.installing = true
        }
        let transaction = SentrySDK.startTransaction(name: "Update App", operation: "updater")
        DispatchQueue.global(qos: .userInteractive).async {
            let lock = DispatchSemaphore(value: 0)
            let span = transaction.startChild(operation: "updater", description: withApp.appMarketingName)
            withApp.updateApp { _ in
                lock.signal()
            }
            lock.wait()
            DispatchQueue.main.async {
                self.installing = false
                transaction.finish()
                span.finish()
            }
            self.fetchData()
        }
    }

    func updateAll() {
        let transaction = SentrySDK.startTransaction(name: "Update All Apps", operation: "updater")
        let lock = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            for app in updatableApps {
                let span = transaction.startChild(operation: "updater", description: app.appMarketingName)
                DispatchQueue.main.async {
                    self.installing = true
                }
                app.updateApp { _ in
                    os_log("Update of %{public}s done.", app.appBundle)
                    lock.signal()
                    span.finish()
                }
                lock.wait()
            }
            DispatchQueue.main.async {
                self.installing = self.installingApps
            }
            transaction.finish()
        }
    }

    func fetchData() {
        if updating {
            return
        }

        apps = AppBundles.bundledApps + SparkleApp.all

        DispatchQueue.global(qos: .userInteractive).async { [self] in
            DispatchQueue.main.async {
                self.updating = true
            }
            for app in self.apps {
                DispatchQueue.main.async {
                    app.status = .GatheringInfo
                }
                if app.hasUpdate {
                    DispatchQueue.main.async {
                        app.updatable = true
                    }
                } else {
                    DispatchQueue.main.async {
                        app.updatable = false
                    }
                }
                os_log("%{public}s latestVersion=%{public}s currentVersion=%{public}s updatable=%{public}s", app.appName, app.latestVersionCached, app.textVersion, app.latestVersion.description)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    app.status = .Idle
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updating = false
            }
        }
    }

    static func readPlistFile(fileURL: URL) -> [String: Any]? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        guard let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }
        return result
    }

    init() {
        apps = (AppBundles.bundledApps + SparkleApp.all).sorted(by: { lha, rha in
            lha.appMarketingName < rha.appMarketingName
        })
    }
}
