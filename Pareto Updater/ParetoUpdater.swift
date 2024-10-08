//
//  Pareto_UpdaterApp.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import Alamofire
import AppUpdater
import Cache
import Combine
import Defaults
import Foundation
import os.log
import Regex
import SettingsAccess
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?
    private var popOver = NSPopover()
    private var shouldTerminate = false

    var appsStore = AppBundles()

    @Default(.hideWhenNoUpdates) private var hideWhenNoUpdates

    // private var noUpdatesSink: AnyCancellable?
    // private var fetchSink: AnyCancellable?
    private var finishedLaunch: Bool = false
    var installWindow: NSWindow?
    private var appInstallView: AppInstall?

    func application(_: NSApplication, open urls: [URL]) {
        for url in urls {
            processAction(url)
        }
    }

    static let updater = GithubAppUpdater(
        updateURL: "https://paretosecurity.app/api/updates?app=updater&uuid=\(Defaults[.machineUUID])&version=\(Constants.appVersion)&os_version=\(Constants.macOSVersionString)&distribution=\(Constants.utmSource)",
        allowPrereleases: Defaults[.betaChannel],
        autoGuard: true,
        interval: 0
    )

    //    func updateHiddenState() {
    //        if hideWhenNoUpdates, finishedLaunch {
    //            statusItem?.isVisible = AppDelegate.bundleModel.haveUpdatableApps
    //        }
    //    }

    func scheduleHourlyCheck() {
        let activity = NSBackgroundActivityScheduler(identifier: "\(String(describing: Bundle.main.bundleIdentifier)).Updater")
        activity.repeats = true
        activity.interval = 60 * 60
        activity.schedule { completion in
            DispatchQueue.global(qos: .userInteractive).async {
                self.appsStore.fetchData()
            }
            try? Constants.versionStorage.removeExpiredObjects()
            completion(.finished)
        }
        try? Constants.versionStorage.removeExpiredObjects()
    }

    func scheduleHourlyUpdateCheck() {
        let activity = NSBackgroundActivityScheduler(identifier: "\(String(describing: Bundle.main.bundleIdentifier)).SelfUpdater")
        activity.repeats = true
        activity.interval = 60 * 60
        activity.schedule { completion in
            DispatchQueue.global(qos: .userInteractive).async { [self] in
                if !(appsStore.workInstall || appsStore.updating || appsStore.installingApps) {
                    _ = AppDelegate.updater.checkAndUpdate()
                }
            }
            completion(.finished)
        }
    }

    func clearCache() {
        do {
            let fileManager = FileManager.default
            let filePaths = try fileManager.contentsOfDirectory(atPath: Constants.cacheFolder.path)
            for filePath in filePaths {
                if filePath.hasSuffix(".dmg") || filePath.hasSuffix(".zip") || filePath.hasSuffix(".pkg") {
                    try fileManager.removeItem(atPath: Constants.cacheFolder.appendingPathComponent(filePath).path)
                }
            }
        } catch {
            os_log("Could not clear temp folder: %{public}s", error.localizedDescription)
        }
        try? Constants.versionStorage.removeAll()
        let alert = NSAlert()
        alert.messageText = "Cache has been cleared."
        alert.alertStyle = NSAlert.Style.informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func copyLogs() {
        NSPasteboard.general.clearContents()
        if let data = try? Constants.logEntries().joined(separator: "\n") {
            NSPasteboard.general.setString(data, forType: .string)
        }
        let alert = NSAlert()
        alert.messageText = "Logs have been copied to the clipboard."
        alert.alertStyle = NSAlert.Style.informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    public func processAction(_ url: URL) {
        switch url.host {
        case "clearCache":
            clearCache()
        case "logs":
            copyLogs()
        case "install":

            if let bundles = url.queryParams()["bundles"]?.lowercased().split(separator: ",").map(String.init) {
                appsStore.apps = AppBundles.bundledApps.filter { bundledApp in
                    bundles.contains(bundledApp.appBundle.lowercased())
                }
                if appsStore.apps.count > 0 {
                    showInstallAppsWindow()
                } else {
                    NSApplication.shared.terminate(self)
                }
            }

        #if !SETAPP_ENABLED
            case "enrollSingle":
                let jwt = url.queryParams()["token"] ?? ""
                do {
                    let license = try VerifyLicense(withLicense: jwt)
                    Defaults[.license] = jwt
                    Defaults[.userEmail] = license.subject
                    Defaults[.userID] = license.uuid
                    Constants.Licensed = true
                    Defaults[.reportingRole] = .personal

                    // If we don't need to verify license return early
                    if license.role != "verify" {
                        return
                    }
                    let parameters: [String: String] = [
                        "uuid": license.uuid,
                        "machineUUID": Defaults[.machineUUID]
                    ]
                    let verifyURL = "https://dash.paretosecurity.com/api/v1/enroll/verify"
                    AF.request(verifyURL, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseString(queue: Constants.httpQueue, completionHandler: { response in
                        if response.error == nil {
                            DispatchQueue.main.async {
                                let alert = NSAlert()
                                alert.messageText = "Pareto Updater is now licensed."
                                alert.alertStyle = NSAlert.Style.informational
                                alert.addButton(withTitle: "OK")
                                #if !DEBUG
                                    alert.runModal()
                                #endif
                            }
                        } else {
                            License.toFree()
                            DispatchQueue.main.async {
                                let alert = NSAlert()
                                alert.messageText = "No more licenses available for this account!"
                                alert.alertStyle = NSAlert.Style.critical
                                alert.addButton(withTitle: "OK")
                                #if !DEBUG
                                    alert.runModal()
                                #endif
                            }
                        }
                    })

                } catch {
                    License.toFree()
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "License is not valid. Please email support@paretosecurity.com."
                        alert.alertStyle = NSAlert.Style.informational
                        alert.addButton(withTitle: "OK")
                        #if !DEBUG
                            alert.runModal()
                        #endif
                    }
                }

            case "enrollTeam":
                if Constants.Licensed || !Defaults[.teamAuth].isEmpty {
                    return
                }

                let jwt = url.queryParams()["token"] ?? ""
                do {
                    let ticket = try VerifyTeamTicket(withTicket: jwt)
                    Defaults[.license] = jwt
                    Defaults[.userID] = ""
                    Defaults[.teamAuth] = ticket.teamAuth
                    Defaults[.teamID] = ticket.teamUUID
                    Constants.Licensed = true
                    Defaults[.reportingRole] = .team
                    Defaults[.isTeamOwner] = ticket.isTeamOwner
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Pareto Updater is now licensed."
                        alert.alertStyle = NSAlert.Style.informational
                        alert.addButton(withTitle: "OK")
                        #if !DEBUG
                            alert.runModal()
                        #endif
                    }
                } catch {
                    License.toFree()
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Team ticket is not valid. Please email support@paretosecurity.com."
                        alert.alertStyle = NSAlert.Style.informational
                        alert.addButton(withTitle: "OK")
                        #if !DEBUG
                            alert.runModal()
                        #endif
                    }
                }
        #endif
        case "reset":
            Defaults.removeAll()
            UserDefaults.standard.removeAll()
            UserDefaults.standard.synchronize()

            if !Constants.isRunningTests {
                NSApplication.shared.terminate(self)
            }
        default:
            os_log("Unknown command \(url)")
        }
    }

    func applicationDidBecomeActive(_: Notification) {
        if Constants.isRunningTests {
            return
        }
        //        if hideWhenNoUpdates {
        //            statusItem?.isVisible = true
        //            finishedLaunch = false
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
        //                finishedLaunch = true
        //                // updateHiddenState()
        //            }
        //        }
    }

    func applicationDidFinishLaunching(_: Notification) {
        if CommandLine.arguments.contains("export") {
            if let json = AppBundles.asJSON() {
                print(json as String)
            }
            exit(0)
        }
        if CommandLine.arguments.contains("installAll") {
            let lock = DispatchSemaphore(value: 0)
            for app in AppBundles.bundledApps.filter({ app in
                !app.isInstalled
            }) {
                print("Downloading \(app.appBundle)")
                app.downloadLatest { sourceFile, appFile in
                    print("Installing \(app.appBundle)")
                    let state = app.install(sourceFile: sourceFile, appFile: appFile)
                    print("\(state) \(app.appBundle) ")
                    lock.signal()
                }
                lock.wait()
            }
            exit(0)
        }
        if CommandLine.arguments.contains("install") {
            let lock = DispatchSemaphore(value: 0)
            for app in AppBundles.bundledApps.filter({ app in
                !app.isInstalled && app.appBundle == CommandLine.arguments.last
            }) {
                print("Downloading \(app.appBundle)")
                app.downloadLatest { sourceFile, appFile in
                    print("Installing \(app.appBundle)")
                    let state = app.install(sourceFile: sourceFile, appFile: appFile)
                    print("\(state) \(app.appBundle) ")
                    lock.signal()
                }
                lock.wait()
            }
            exit(0)
        }
        if Constants.isRunningTests {
            return
        }
        // Verify license
        #if !SETAPP_ENABLED
            do {
                switch Defaults[.reportingRole] {
                case .personal:
                    _ = try VerifyLicense(withLicense: Defaults[.license])
                    Constants.Licensed = true
                case .team:
                    _ = try VerifyTeamTicket(withTicket: Defaults[.license])
                    Constants.Licensed = true
                default:
                    License.toFree()
                }
            } catch {
                License.toFree()
            }
        #else
            Constants.Licensed = true
        #endif

        popOver.behavior = .transient
        popOver.animates = true
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: AppList().environmentObject(appsStore).openSettingsAccess())

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let menuButton = statusItem?.button {
            let view = NSHostingView(rootView: MenuBarView().environmentObject(appsStore))
            view.translatesAutoresizingMaskIntoConstraints = false
            menuButton.addSubview(view)
            menuButton.target = self
            menuButton.isEnabled = true
            // menuButton.image = NSImage(named: "menubar")
            menuButton.action = #selector(menuButtonToggle(sender:))
            menuButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: menuButton.topAnchor),
                view.leadingAnchor.constraint(equalTo: menuButton.leadingAnchor),
                view.widthAnchor.constraint(equalTo: menuButton.widthAnchor),
                view.bottomAnchor.constraint(equalTo: menuButton.bottomAnchor)
            ])
        }

        statusMenu = NSMenu(title: "ParetoUpdater")

        let contactItem = NSMenuItem(title: "Contact Support", action: #selector(AppDelegate.contact), keyEquivalent: "c")
        contactItem.target = NSApp.delegate
        statusMenu?.addItem(contactItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(AppDelegate.quitApp), keyEquivalent: "q")
        quitItem.target = NSApp.delegate
        statusMenu?.addItem(quitItem)

        //        if hideWhenNoUpdates {
        //            statusItem?.isVisible = true
        //            finishedLaunch = false
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
        //                finishedLaunch = true
        //                updateHiddenState()
        //            }
        //        }

        if !Constants.isRunningTests {
            DispatchQueue.global(qos: .utility).async { [self] in
                _ = AppDelegate.updater.checkAndUpdate()
                scheduleHourlyCheck()
                scheduleHourlyUpdateCheck()
            }
        }

        // update state on all changes
        // fetchSink = AppDelegate.bundleModel.$updating.sink { [self] _ in
        //     updateHiddenState()
        //     popOver.contentViewController?.viewDidLayout()
        //     popOver.contentViewController?.viewDidAppear()
        // popOver.contentSize = popOver.contentViewController?.view.intrinsicContentSize ?? NSMakeSize(10, 10)
        //  }
        // noUpdatesSink = Defaults.publisher(.hideWhenNoUpdates).sink { [self] _ in
        //     updateHiddenState()
        //     popOver.contentViewController?.viewDidLayout()
        //     popOver.contentViewController?.viewDidAppear()
        // popOver.contentSize = popOver.contentViewController?.view.intrinsicContentSize ?? NSMakeSize(10, 10)
        // }

        statusItem?.isVisible = !shouldTerminate
    }

    @objc
    func menuButtonToggle(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == NSEvent.EventType.rightMouseUp {
            statusItem?.menu = statusMenu!

        } else {
            if popOver.isShown {
                popOver.close()
            } else {
                popOver.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
                popOver.contentViewController?.view.window?.makeKey()
                popOver.contentViewController?.view.window?.level = .floating
                popOver.contentSize = popOver.contentViewController?.view.intrinsicContentSize ?? NSSize(width: 10, height: 10)
            }
        }
    }

    @objc
    func quitApp() {
        NSApplication.shared.terminate(self)
    }

    @objc
    func contact() {
        // showInstallAppsWindow()
        NSWorkspace.shared.open(Constants.bugReportURL)
    }

    func showInstallAppsWindow() {
        shouldTerminate = true
        statusItem?.isVisible = false
        NSApp.setActivationPolicy(.regular)
        if installWindow == nil {
            installWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 380),
                styleMask: [.closable, .titled, .unifiedTitleAndToolbar],
                backing: .buffered,
                defer: false
            )
            installWindow?.title = "Pareto Updater"
            installWindow?.titleVisibility = .visible
            installWindow?.titlebarAppearsTransparent = false
            installWindow?.center()
            installWindow?.setFrameAutosaveName("installView")
            installWindow?.isReleasedWhenClosed = false

            let hosting = NSHostingView(rootView: AppInstall().environmentObject(appsStore))
            hosting.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
            installWindow?.contentView = hosting
            installWindow?.makeKeyAndOrderFront(nil)
            DispatchQueue.global(qos: .userInteractive).async { [self] in
                appsStore.fetchData()
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        shouldTerminate
    }
}

@main
struct ParetoUpdaterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("showMenuBar") var showMenuBar = true
    var body: some Scene {
        Settings {
            PreferencesView(selected: PreferencesView.Tabs.general).environmentObject(appDelegate.appsStore)
        }
    }
}
