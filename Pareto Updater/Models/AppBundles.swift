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

    func updateAll() {
        for app in apps {
            if app.updatable {
                app.updateApp { _ in
                    os_log("Update of %{public}s  done.", app.appBundle)
                    app.updatable = false
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
                app.fetching = true

                if app.latestVersion > app.currentVersion {
                    app.updatable = true
                } else {
                    app.updatable = false
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
            AppSlack.sharedInstance
        ]
    }
}
