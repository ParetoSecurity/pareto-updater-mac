//
//  Bundle.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Foundation
import os.log
import SwiftUI

extension Bundle {
    var isCodeSigned: Bool {
        return !Process.run(app: "/usr/bin/codesign", args: ["-dv", bundlePath]).contains("Error")
    }

    var codeSigningIdentity: String? {
        let lines = Process.run(app: "/usr/bin/codesign", args: ["-dvvv", bundlePath]).split(separator: "\n")
        for line in lines {
            if line.hasPrefix("TeamIdentifier=") {
                return String(line.dropFirst(15))
            }
        }
        return nil
    }
    
    static func plistDict (path: URL) -> NSDictionary? {
        let plist = path.appendingPathComponent("/Contents/Info.plist")
        return NSDictionary(contentsOf: plist)
    }
    
    static func appVersion(path: URL, key: String = "CFBundleShortVersionString") -> String? {
        plistDict(path: path)?.value(forKey: key) as? String
    }

    var icon: NSImage? {
        if let appPath = URL(string: path.string)?.path {
            return NSWorkspace.shared.icon(forFile: appPath)
        }

        if let iconFile = infoDictionary?["CFBundleIconFile"] as? String {
            return image(forResource: iconFile)
        }

        return nil
    }

    func launch() {
        NSWorkspace.shared.openApplication(at: bundleURL, configuration: NSWorkspace.OpenConfiguration())
    }
}
