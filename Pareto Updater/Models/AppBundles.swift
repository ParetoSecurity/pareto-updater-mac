//
//  Apps.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Foundation
import os.log

protocol AppBundle {
    var apps: [AppUpdater] { get set }
    var updating: Bool { get set }
    var installing: Bool { get set }
}

class AppBundles: AppBundle, ObservableObject {
    @Published var apps: [AppUpdater]
    @Published var updating: Bool = false
    @Published var installing: Bool = false

    public var haveUpdatableApps: Bool {
        !updatableApps.isEmpty
    }

    public var updatableApps: [AppUpdater] {
        apps.filter { app in
            app.updatable && app.isInstalled
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
        DispatchQueue.global(qos: .userInteractive).async {
            let lock = DispatchSemaphore(value: 0)
            withApp.updateApp { [self] _ in
                lock.wait()
                DispatchQueue.main.async {
                    self.installing = false
                }
                self.fetchData()
            }
        }
    }

    func updateAll() {
        let lock = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            for app in updatableApps {
                DispatchQueue.main.async {
                    self.installing = true
                }
                app.updateApp { _ in
                    os_log("Update of %{public}s done.", app.appBundle)
                    lock.signal()
                }
                lock.wait()
            }
            DispatchQueue.main.async {
                self.installing = self.installingApps
            }
        }
    }

    func fetchData() {
        if updating || installing {
            return
        }

        DispatchQueue.global(qos: .userInteractive).async { [self] in
            DispatchQueue.main.async {
                self.updating = true
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
                self.updating = false
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
