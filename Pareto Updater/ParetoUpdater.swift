//
//  Pareto_UpdaterApp.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import AppUpdater
import Cache
import Combine
import Defaults
import Foundation
import os.log
import Regex
import SwiftUI
import Version

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?
    private var popOver = NSPopover()
    static let bundleModel = AppBundles()

    @Default(.hideWhenNoUpdates) private var hideWhenNoUpdates

    private var noUpdatesSink: AnyCancellable?
    private var fetchSink: AnyCancellable?
    private var finishedLaunch: Bool = false

    static let updater = GithubAppUpdater(
        updateURL: "https://paretosecurity.app/api/updates?app=updater&uuid=\(Defaults[.machineUUID])&version=\(Constants.appVersion)&os_version=\(Constants.macOSVersionString)&distribution=\(Constants.utmSource)",
        allowPrereleases: Defaults[.betaChannel],
        autoGuard: true,
        interval: 60 * 60
    )

    func updateHiddenState() {
        if hideWhenNoUpdates, finishedLaunch {
            statusItem?.isVisible = AppDelegate.bundleModel.haveUpdatableApps
        }
    }

    func scheduleHourlyCheck() {
        let activity = NSBackgroundActivityScheduler(identifier: "\(String(describing: Bundle.main.bundleIdentifier)).Updater")
        activity.repeats = true
        activity.interval = 60 * 60
        activity.schedule { completion in
            AppDelegate.bundleModel.fetchData()
            completion(.finished)
        }
    }

    func applicationDidBecomeActive(_: Notification) {
        if hideWhenNoUpdates {
            statusItem?.isVisible = true
            finishedLaunch = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
                finishedLaunch = true
                updateHiddenState()
            }
        }
    }

    func applicationDidFinishLaunching(_: Notification) {
        #if !DEBUG
            if !AppInfo.isRunningTests {
                SentrySDK.start { options in
                    options.dsn = "https://9f78692775d244589bf08c21749f20fb@o32789.ingest.sentry.io/6539843"
                    options.enableAutoSessionTracking = true
                    options.enableAutoPerformanceTracking = true
                    options.tracesSampleRate = 1.0

                    let user = User()
                    user.userId = Defaults[.machineUUID]
                    SentrySDK.setUser(user)
                }
            }
        #endif

        if CommandLine.arguments.contains("-update") {
            for app in AppDelegate.bundleModel.apps {
                if app.latestVersion > app.currentVersion {
                    app.updateApp { _ in
                        os_log("Update of %{public}s  done.", app.appBundle)
                    }
                }
            }
            exit(0)
        }

        popOver.behavior = .transient
        popOver.animates = true
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: AppList(viewModel: AppDelegate.bundleModel))

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.isVisible = true

        if let menuButton = statusItem?.button {
            let view = NSHostingView(rootView: Menubar())
            view.translatesAutoresizingMaskIntoConstraints = false
            menuButton.addSubview(view)
            menuButton.target = self
            menuButton.isEnabled = true
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

        let preferencesItem = NSMenuItem(title: "Preferences", action: #selector(AppDelegate.preferences), keyEquivalent: ",")
        preferencesItem.target = NSApp.delegate
        statusMenu?.addItem(preferencesItem)

        let contactItem = NSMenuItem(title: "Contact Support", action: #selector(AppDelegate.contact), keyEquivalent: "c")
        contactItem.target = NSApp.delegate
        statusMenu?.addItem(contactItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(AppDelegate.quitApp), keyEquivalent: "q")
        quitItem.target = NSApp.delegate
        statusMenu?.addItem(quitItem)

        if hideWhenNoUpdates {
            statusItem?.isVisible = true
            finishedLaunch = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
                finishedLaunch = true
                updateHiddenState()
            }
        }

        DispatchQueue.main.async { [self] in
            _ = AppDelegate.updater.checkAndUpdate()
            scheduleHourlyCheck()
        }

        // update state on all changes
        fetchSink = AppDelegate.bundleModel.$updating.sink { [self] _ in
            updateHiddenState()
            popOver.contentViewController?.viewDidLayout()
            popOver.contentViewController?.viewDidAppear()
        }
        noUpdatesSink = Defaults.publisher(.hideWhenNoUpdates).sink { [self] _ in
            updateHiddenState()
            popOver.contentViewController?.viewDidLayout()
            popOver.contentViewController?.viewDidAppear()
        }
        AppDelegate.bundleModel.fetchData()
    }

    @objc
    func menuButtonToggle(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == NSEvent.EventType.rightMouseUp {
            statusItem?.popUpMenu(statusMenu!)

        } else {
            if popOver.isShown {
                popOver.close()
            } else {
                popOver.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
                popOver.contentViewController?.view.window?.makeKey()
                popOver.contentViewController?.view.window?.level = .floating
            }
        }
    }

    @objc
    func quitApp() {
        NSApplication.shared.terminate(self)
    }

    @objc
    func contact() {
        NSWorkspace.shared.open(Constants.bugReportURL)
    }

    @objc
    func preferences() {
        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct ParetoUpdaterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            PreferencesView(selected: PreferencesView.Tabs.general)
        }
    }
}
