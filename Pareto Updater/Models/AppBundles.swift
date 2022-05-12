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

    @Published var fetching: Bool = false

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
        DispatchQueue.global(qos: .background).async { [self] in
            withApp.updateApp { _ in
                self.fetchData()
            }
        }
    }

    func updateAll() {
        DispatchQueue.global(qos: .background).async { [self] in
            for app in updatableApps {
                app.updateApp { _ in
                    os_log("Update of %{public}s done.", app.appBundle)
                }
            }
        }
    }

    func fetchData() {
        if fetching {
            return
        }

        DispatchQueue.global(qos: .background).async { [self] in
            DispatchQueue.main.async {
                self.fetching = true
            }
            for app in self.installedApps {
                DispatchQueue.main.async {
                    app.status = .GatheringInfo
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
                    app.status = .Idle
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.fetching = false
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
            AppLibreOffice.sharedInstance,
            AppSpyBuster.sharedInstance
        ].sorted(by: { lha, rha in
            lha.appMarketingName < rha.appMarketingName
        })
    }
}
