//
//  Pareto_UpdaterApp.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import Cache
import Foundation
import SwiftUI
import Version
import AppUpdater

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popOver = NSPopover()
    let view = AppList()
    
    static let updater = GithubAppUpdater(
        updateURL: "https://api.github.com/repos/paretosecurity/pareto-updater-mac/releases",
        allowPrereleases: false,
        autoGuard: true,
        interval: 60 * 60
    )
    
    func applicationDidFinishLaunching(_: Notification) {
        popOver.behavior = .transient
        popOver.animates = true
        popOver.contentViewController = NSViewController()
        popOver.contentViewController?.view = NSHostingView(rootView: view)
        popOver.contentViewController?.view.window?.makeKey()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let menuButton = statusItem?.button {
            menuButton.image = NSImage(systemSymbolName: "square.and.arrow.down.on.square", accessibilityDescription: nil)
            menuButton.action = #selector(menuButtonToggle)
        }
        DispatchQueue.main.async {
            _ = AppDelegate.updater.checkAndUpdate()
        }
    }

    @objc
    func menuButtonToggle(sender _: AnyObject) {
        if popOver.isShown {
            popOver.close()
        } else {
            if let menuButton = statusItem?.button {
                popOver.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .minY)
            }
        }
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
}
