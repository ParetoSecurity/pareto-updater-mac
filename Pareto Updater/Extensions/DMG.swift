//
//  DMG.swift
//  Pareto Updater
//
//  Created by Janez Troha on 20/04/2022.
//

import Foundation
import IOKit.storage
import os.log

public enum DMGMounter {
    private static func hdiutil(withCMD cmd: [String]) -> Bool {
        os_log("Running hdiutil with : \(cmd.joined(separator: " "))")
        let process = Process.launchedProcess(launchPath: "/usr/bin/hdiutil", arguments: cmd)
        process.waitUntilExit()
        return process.terminationStatus == 0
    }

    public static func attach(diskImage: URL, at mountPoint: URL) -> Bool {
        let cmd = ["attach", diskImage.path, "-nobrowse", "-mountpoint", mountPoint.path, "-noverify", "-quiet", "-noautoopen"]
        return DMGMounter.hdiutil(withCMD: cmd)
    }

    public static func detach(mountPoint: URL) -> Bool {
        let cmd = ["detach", mountPoint.path, "-quiet"]
        return DMGMounter.hdiutil(withCMD: cmd)
    }
}
