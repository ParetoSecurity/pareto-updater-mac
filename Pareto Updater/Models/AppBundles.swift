//
//  Apps.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Cocoa
import Foundation
import os.log
#if !DEBUG
    import Sentry
#endif
struct PublicApp: Codable {
    let bundle: String
    let name: String
    let description: String
    let icon: String
}

class AppBundles: ObservableObject {
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
        AppGitHub.sharedInstance,
        AppCyberduck.sharedInstance,
        AppITerm.sharedInstance,
        AppZoom.sharedInstance,
        AppIINA.sharedInstance,
        AppMTeams.sharedInstance,
        AppMacy.sharedInstance,
        AppSwiftBar.sharedInstance,
        AppRectangle.sharedInstance,
        AppHiddenBar.sharedInstance,
        AppGitUp.sharedInstance,
        AppWorkHours.sharedInstance,
        AppHandBrake.sharedInstance
    ]

    @Published var apps: [AppUpdater]

    @Published var updating: Bool = false
    @Published var workInstall: Bool = false
    @Published var fetchedOnce: Bool = false

    public var haveUpdatableApps: Bool {
        !updatableApps.isEmpty
    }

    public var haveInstallableApps: Bool {
        return apps.filter { app in
            !app.isInstalled
        }.count > 0
    }

    public var updatableApps: [AppUpdater] {
        if fetchedOnce {
            return apps.filter { app in
                app.isInstalled && app.usedRecently && app.hasUpdate && !app.fromAppStore
            }
        }
        return []
    }

    public var installingApps: Bool {
        apps.allSatisfy { app in
            app.status != .Idle
        }
    }

    public var installedApps: [AppUpdater] {
        if fetchedOnce {
            return apps.filter { app in
                app.isInstalled && app.latestVersion != "0.0.0"
            }
        }
        return []
    }

    func FreeVersionAlert() {
        let alert = NSAlert()
        alert.messageText = "Updating is disabled in the free version."
        alert.alertStyle = NSAlert.Style.informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Buy License")
        let response = alert.runModal()

        if response == .alertSecondButtonReturn {
            NSWorkspace.shared.open(Constants.buyURL)
        }
    }

    func updateApp(withApp: AppUpdater) {
        if !Constants.Licensed {
            FreeVersionAlert()
            return
        }

        DispatchQueue.main.async {
            self.workInstall = true
        }

        DispatchQueue.global(qos: .userInteractive).async {
            let lock = DispatchSemaphore(value: 0)
            withApp.updateApp { _ in
                DispatchQueue.main.async {
                    withApp.updatable = false
                }
                lock.signal()
            }
            lock.wait()
            DispatchQueue.main.async {
                self.workInstall = false
            }
        }
    }

    func install(fromQueue queue: [AppUpdater]) {
        DispatchQueue.main.async {
            self.workInstall = true
        }
        DispatchQueue.global(qos: .userInteractive).async {
            let worker = DispatchQueue(label: "install.queue", attributes: .concurrent)

            for app in queue {
                worker.sync(flags: .barrier) {
                    let lock = DispatchSemaphore(value: 0)
                    app.updateApp { _ in
                        DispatchQueue.main.async {
                            app.updatable = false
                        }
                        lock.signal()
                    }
                    lock.wait()
                }
            }

            DispatchQueue.main.async {
                self.workInstall = false
            }
        }
    }

    func installAll() {
        install(fromQueue: apps.filter { app in
            app.hasUpdate || !app.isInstalled
        })
    }

    func updateAll() {
        if !Constants.Licensed {
            FreeVersionAlert()
            return
        }

        install(fromQueue: updatableApps)
    }

    func fetchData() {
        if updating || workInstall {
            return
        }

        let lock = DispatchSemaphore(value: 0)
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
                os_log("%{public}s latestVersion=%{public}s currentVersion=%{public}s updatable=%{public}s", app.appName, app.latestVersion, app.textVersion, app.latestVersion.description)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    app.status = .Idle
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updating = false
            }
            lock.signal()
        }
        lock.wait()
        DispatchQueue.main.async { [self] in
            fetchedOnce = true
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

    static func asJSON() -> String? {
        var export: [PublicApp] = []

        for app in AppBundles.bundledApps.sorted(by: { lha, rha in
            lha.appMarketingName.lowercased() < rha.appMarketingName.lowercased()
        }) {
            if let icon = app.icon?.base64 {
                export.append(PublicApp(
                    bundle: app.appBundle.lowercased(),
                    name: app.appMarketingName,
                    description: "",
                    icon: icon
                ))
            }
        }

        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(export)
        guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else { return nil }

        return json
    }

    init() {
        apps = (AppBundles.bundledApps + SparkleApp.all).sorted(by: { lha, rha in
            lha.appMarketingName.lowercased() < rha.appMarketingName.lowercased()
        })
    }
}
