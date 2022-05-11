//
//  Apps.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Foundation
import os.log

class AppBundles: ObservableObject {
    @Published var apps: [AppUpdater]

    @Published var fetching = false

    public var haveUpdatableApps: Bool {
        !updatableApps.isEmpty
    }

    public var updatableApps: [AppUpdater] {
        apps.filter { app in
            app.updatable && app.isInstalled
        }
    }

    public var installedApps: [AppUpdater] {
        apps.filter { app in
            app.isInstalled
        }
    }

    func updateApp(withApp: AppUpdater) {
        DispatchQueue.main.async {
            self.fetching = true
        }
        DispatchQueue.global(qos: .background).async { [self] in
            withApp.updateApp { _ in
                self.fetching = false
                self.fetchData()
            }
        }
    }

    func updateAll() {
        fetching = true
        DispatchQueue.global(qos: .background).async { [self] in
            for app in updatableApps {
                DispatchQueue.global(qos: .background).async {
                    app.updateApp { _ in
                        os_log("Update of %{public}s  done.", app.appBundle)
                        app.updatable = false
                        app.fetching = false
                    }
                }
            }
        }
    }

    func fetchData() {
        DispatchQueue.global(qos: .background).async {
            if self.fetching {
                os_log("Prevent refresh one already running.")
                return
            }
            DispatchQueue.main.async {
                os_log("Refresh starting.")
                self.fetching = true
            }
            for app in self.apps {
                DispatchQueue.main.async {
                    app.fetching = true
                    app.fractionCompleted = 0.0
                }

                if app.latestVersion > app.currentVersion {
                    DispatchQueue.main.async {
                        app.updatable = true
                    }
                } else {
                    DispatchQueue.main.async {
                        app.updatable = false
                    }
                }
                os_log("%{public}s latestVersion=%{public}s currentVersion=%{public}s updatable=%{public}s", app.appName, app.latestVersion.description, app.currentVersion.description, app.updatable.description)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    app.fetching = false
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.fetching = false
                os_log("Refresh done.")
            }
        }
    }

    init() {
        apps = [
            AppSignal.sharedInstance,
            AppFirefox.sharedInstance,
            AppGoogleChrome.sharedInstance,
            AppSublimeText.sharedInstance,
            AppSlack.sharedInstance,
            AppDocker.sharedInstance,
            AppLibreOffice.sharedInstance
        ].sorted(by: { lha, rha in
            lha.appMarketingName > rha.appMarketingName
        })
    }
}
