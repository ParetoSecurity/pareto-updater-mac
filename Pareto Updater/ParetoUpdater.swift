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

import Alamofire

#if !DEBUG
    import Sentry
#endif
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

    public func processAction(_ url: URL) {
        #if !DEBUG
            let crumb = Breadcrumb()
            crumb.level = SentryLevel.info
            crumb.category = "processAction"
            crumb.message = url.debugDescription
            SentrySDK.addBreadcrumb(crumb: crumb)
        #endif
        switch url.host {
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

        #if !DEBUG
            if !Constants.isRunningTests {
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

        if !Constants.isRunningTests {
            DispatchQueue.main.async { [self] in
                _ = AppDelegate.updater.checkAndUpdate()
                scheduleHourlyCheck()
            }
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
