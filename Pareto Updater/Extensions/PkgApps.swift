//
//  PkgApps.swift
//  Pareto Updater
//
//  Created by Janez Troha on 01/07/2022.
//

import Foundation
import os.log
import Path

class PkgApp: AppUpdater {
    private var pkg: String
    private var pkgAppName: String

    init(appBundle: String, pkgName: String, appPkgName: String) {
        pkg = pkgName
        pkgAppName = appPkgName
        super.init(appBundle: appBundle)
    }

    override var latestURLExtension: String {
        "pkg"
    }

    override func extract(sourceFile _: URL, appFile: URL, needsStart: Bool) -> AppUpdaterStatus {
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory(),
                           isDirectory: true).appendingPathComponent(appBundle)
        try? Path(tempPath.path)?.delete()

        do {
            let pkgRes = Process.run(app: "/usr/sbin/pkgutil", args: [
                "--expand",
                appFile.path,
                tempPath.path

            ])
            let tarRes = Process.run(app: "/usr/bin/tar", args: [
                "xf",
                tempPath
                    .appendingPathComponent(pkg, isDirectory: true)
                    .appendingPathComponent("Payload")
                    .path,

                "-C",
                tempPath.path
            ])
            if tarRes.contains("Unrecognized archive format") {
                if !Process.runCMDasAdmin(cmd: "/usr/sbin/installer -pkg \(appFile.path) -target /") {
                    os_log("Install of pkg failed using admin: \(appFile.path)")
                    return AppUpdaterStatus.Failed
                }
                if let bundle = Bundle(url: applicationPath), needsStart {
                    bundle.launch()
                }
                try? Path(tempPath.path)?.delete()
                return AppUpdaterStatus.Installed
            } else {
                let app = tempPath.appendingPathComponent(pkgAppName)
                if let downloadedAppBundle = Bundle(url: app) {
                    if let installedAppBundle = Bundle(url: applicationPath) {
                        if !validate(downloadedAppBundle, installedAppBundle) {
                            os_log("Failed to validate app bundle %{public}s", appBundle)
                            return AppUpdaterStatus.Failed
                        }

                        do {
                            os_log("Delete installedAppBundle: \(installedAppBundle.path.string)")
                            try installedAppBundle.path.delete()
                            os_log("Update installedAppBundle: \(installedAppBundle.description) with \(downloadedAppBundle.description)")
                            try downloadedAppBundle.path.copy(to: installedAppBundle.path, overwrite: true)
                        } catch {
                            os_log("Delete installedAppBundle failed: \(installedAppBundle.path.string) \(error.localizedDescription)")
                            if !Process.runCMDasAdmin(cmd: "/bin/rm -rf \(installedAppBundle.path.string)") {
                                os_log("Delete installedAppBundle failed using admin: \(installedAppBundle.path.string)")
                                return AppUpdaterStatus.Failed
                            }
                            os_log("Update installedAppBundle: \(installedAppBundle.description) with \(downloadedAppBundle.description)")
                            try downloadedAppBundle.path.copy(to: installedAppBundle.path, overwrite: true)
                        }

                        if needsStart {
                            installedAppBundle.launch()
                        }
                    } else {
                        os_log("Install AppBundle \(downloadedAppBundle.description)")
                        try downloadedAppBundle.path.copy(to: Path(applicationPath.path)!, overwrite: true)
                    }

                    if let bundle = Bundle(url: applicationPath), needsStart {
                        bundle.launch()
                    }
                    try? Path(tempPath.path)?.delete()
                    return AppUpdaterStatus.Installed
                }
            }
            return AppUpdaterStatus.Failed
        } catch {
            try? Path(tempPath.path)?.delete()
            os_log("Failed to check for app bundle %{public}s", error.localizedDescription)
            return AppUpdaterStatus.Failed
        }
    }
}
