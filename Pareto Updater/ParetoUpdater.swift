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
        updateURL: "https://api.github.com/repos/paretosecurity/pareto-updater-mac/releases",
        allowPrereleases: false,
        autoGuard: true,
        interval: 60 * 60
    )

    func updateHiddenState() {
        if hideWhenNoUpdates, finishedLaunch {
            statusItem?.isVisible = AppDelegate.bundleModel.haveUpdatableApps
        }
    }

    func applicationWillFinishLaunching(_: Notification) {
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
        popOver.behavior = .transient
        popOver.animates = true
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: AppList(viewModel: AppDelegate.bundleModel))
        popOver.contentViewController?.view.window?.makeKey()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.isVisible = true
        if let menuButton = statusItem?.button {
            menuButton.image = NSImage(systemSymbolName: "square.and.arrow.down.on.square", accessibilityDescription: nil)
            menuButton.action = #selector(menuButtonToggle(sender:))
            menuButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        statusMenu = NSMenu(title: "ParetoUpdater")

        let showItem = NSMenuItem(title: "Show / Hide", action: #selector(AppDelegate.menuButtonToggle(sender:)), keyEquivalent: "s")
        showItem.target = NSApp.delegate
        statusMenu?.addItem(showItem)

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
        fetchSink = AppDelegate.bundleModel.$fetching.sink { _ in
            self.updateHiddenState()
        }
        noUpdatesSink = Defaults.publisher(.hideWhenNoUpdates).sink { _ in
            self.updateHiddenState()
        }
        AppDelegate.bundleModel.fetchData()
    }

    @objc
    func menuButtonToggle(sender _: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.rightMouseUp {
            statusItem?.popUpMenu(statusMenu!)
        } else {
            if popOver.isShown {
                popOver.close()
            } else {
                if let menuButton = statusItem?.button {
                    popOver.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .minY)
                }
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
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
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

public enum Constants {
    static let helpURL = URL(string: "https://github.com/maxgoedjen/secretive/blob/main/FAQ.md")!
    static let httpQueue = DispatchQueue(label: "co.niteo.paretoupdater.fetcher", qos: .userInitiated, attributes: .concurrent)
    static let useEdgeCache = false
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    static let buildVersion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    static let machineName: String = Host.current().localizedName!
    static let macOSVersion = ProcessInfo.processInfo.operatingSystemVersion
    static let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    static let macOSVersionString = "\(macOSVersion.majorVersion).\(macOSVersion.minorVersion).\(macOSVersion.patchVersion)"
    static var isRunningTests: Bool {
        ProcessInfo.processInfo.arguments.contains("isRunningTests") || ProcessInfo.processInfo.environment["CI"] ?? "false" != "false"
    }

    #if DEBUG
        static let versionStorage = try! Storage<String, Version>(
            diskConfig: DiskConfig(name: "Version+Bundles+Debug", expiry: .seconds(1)),
            memoryConfig: MemoryConfig(expiry: .seconds(1)),
            transformer: TransformerFactory.forCodable(ofType: Version.self) // Storage<String, Version>
        )
    #else
        static let versionStorage = try! Storage<String, Version>(
            diskConfig: DiskConfig(name: "Version+Bundles", expiry: .seconds(3600 * 24)),
            memoryConfig: MemoryConfig(expiry: .seconds(3600 * 24 * 2)),
            transformer: TransformerFactory.forCodable(ofType: Version.self) // Storage<String, Version>
        )
    #endif

    static let bugReportURL = { () -> URL in
        let baseURL = "https://paretosecurity.com/report-bug?"
        let logs = logEntries().joined(separator: "\n").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let versions = getVersions().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        if let url = URL(string: baseURL + "&logs=" + logs! + "&version=" + versions!) {
            return url
        }

        return URL(string: baseURL)!
    }()

    static let getVersions = { () -> String in
        "HW: \(hwModelName)\nmacOS: \(macOSVersionString)\nApp: Pareto Updater\nApp Version: \(appVersion)\nBuild: \(buildVersion)"
    }

    static var hwModel: String {
        HWInfo(forKey: "model")
    }

    static var hwModelName: String {
        // Depending on if your serial number is 11 or 12 characters long take the last 3 or 4 characters, respectively, and feed that to the following URL after the ?cc=XXXX part.
        let nameRegex = Regex("<configCode>(.+)</configCode>")
        let cc = hwSerial.count <= 11 ? hwSerial.suffix(3) : hwSerial.suffix(4)
        let url = URL(string: "https://support-sp.apple.com/sp/product?cc=\(cc)")!
        let data = try? String(contentsOf: url)
        if data != nil {
            let nameResult = nameRegex.firstMatch(in: data ?? "")
            return nameResult?.groups.first?.value ?? hwModel
        }

        return hwModel
    }

    static var hwSerial: String {
        HWInfo(forKey: "IOPlatformSerialNumber")
    }

    static let logEntries = { () -> [String] in
        var logs = [String]()

        logs.append("Location: \(Bundle.main.path)")
        logs.append("Build:")

        logs.append("\nLogs:")
        logs.append("Please copy the logs from the Console app by searching for the Pareto Updater.")
        return logs
    }
}

func HWInfo(forKey key: String) -> String {
    let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                              IOServiceMatching("IOPlatformExpertDevice"))

    guard let info = (IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
        return "Unknown"
    }
    IOObjectRelease(service)
    return info
}
