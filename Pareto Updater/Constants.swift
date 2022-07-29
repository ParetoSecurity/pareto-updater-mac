//
//  Constants.swift
//  Pareto Updater
//
//  Created by Janez Troha on 16/05/2022.
//

import AppUpdater
import Cache
import Combine
import Defaults
import Foundation
import os.log
import OSLog
import Regex
import SwiftUI

public enum Constants {
    static let unsupportedBundles: Set<String> = [
        "com.hegenberg.BetterTouchTool",
        "com.culturedcode.ThingsMac"
    ]

    static let helpURL = URL(string: "https://github.com/maxgoedjen/secretive/blob/main/FAQ.md")!
    static let httpQueue = DispatchQueue(label: "co.niteo.paretoupdater.fetcher", qos: .userInitiated, attributes: .concurrent)
    static let useEdgeCache = true
    static var Licensed = false
    static let useCacheFolder = true
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    static let buildVersion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    static let machineName: String = Host.current().localizedName!
    #if DEBUG
        static let versionStorage = try! Storage<String, String>(
            diskConfig: DiskConfig(name: "Version+Bundles+Debug", expiry: .seconds(1), directory: cacheFolder),
            memoryConfig: MemoryConfig(expiry: .seconds(1)),
            transformer: TransformerFactory.forCodable(ofType: String.self) // Storage<String, String>
        )
    #else
        static let versionStorage = try! Storage<String, String>(
            diskConfig: DiskConfig(name: "Version+Bundles+v3", expiry: .seconds(3600), directory: cacheFolder),
            memoryConfig: MemoryConfig(expiry: .seconds(60)),
            transformer: TransformerFactory.forCodable(ofType: String.self) // Storage<String, String>
        )
    #endif
    static let macOSVersion = ProcessInfo.processInfo.operatingSystemVersion
    static let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(Bundle.main.bundleIdentifier ?? "co.niteo.ParetoUpdater")
    static let macOSVersionString = "\(macOSVersion.majorVersion).\(macOSVersion.minorVersion).\(macOSVersion.patchVersion)"
    static var isRunningTests: Bool {
        let env = ProcessInfo.processInfo.environment
        let args = ProcessInfo.processInfo.arguments
        return env["XCTestConfigurationFilePath"] != nil || args.contains("isRunningTests") || env["CI"] ?? "false" != "false"
    }

    static let bugReportURL = { () -> URL in
        let baseURL = "https://paretosecurity.com/report-bug?"
        let versions = getVersions().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        if let url = URL(string: baseURL + "&version=" + versions!) {
            return url
        }

        return URL(string: baseURL)!
    }()

    static let getVersions = { () -> String in
        "HW: \(hwModelName) macOS: \(macOSVersionString) App: Pareto Updater App Version: \(appVersion)\nBuild: \(buildVersion)"
    }

    static var hwModel: String {
        HWInfo(forKey: "model")
    }

    public static func getSystemUUID() -> String? {
        let dev = IOServiceMatching("IOPlatformExpertDevice")
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, dev)
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0)
        IOObjectRelease(platformExpert)
        return serialNumberAsCFString!.takeUnretainedValue() as? String
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
        logs.append("Build: \(Constants.utmSource)")

        logs.append("\nLogs:")

        if #available(macOS 12.0, *) {
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)
            // Get all the logs from the last hour.
            let oneHourAgo = logStore.position(date: Date().addingTimeInterval(-3600))

            // Fetch log objects.
            let allEntries = try logStore.getEntries(at: oneHourAgo)

            // Filter the log to be relevant for our specific subsystem
            // and remove other elements (signposts, etc).
            for log in allEntries
                .compactMap({ $0 as? OSLogEntryLog })
                .filter({ entry in
                    entry.subsystem == Bundle.main.bundleIdentifier
                }) {
                logs.append("\(log.subsystem): \(log.composedMessage)")
            }
        } else {
            logs.append("Please copy the logs from the Console app by searching for the \(Bundle.main.bundleIdentifier).")
        }

        return logs
    }

    static var utmSource: String {
        var source = "app"

        #if DEBUG
            source += "-debug"
        #else

            if Defaults[.betaChannel] {
                source += "-pre"
            } else {
                source += "-live"
            }

        #endif

        #if SETAPP_ENABLED
            source += "-setapp"
        #else
            if Licensed {
                if Defaults[.teamID].isEmpty {
                    source += "-personal"
                } else {
                    source += "-team"
                }
            } else {
                source += "-opensource"
            }
        #endif

        return source
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

func viaEdgeCache(_ url: String) -> String {
    if Constants.useEdgeCache {
        return url.replacingOccurrences(of: "https://", with: "https://pareto-cache.team-niteo.workers.dev/")
    }
    return url
}
