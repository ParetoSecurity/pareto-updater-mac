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
        return !runCMD(app: "/usr/bin/codesign", args: ["-dv", bundlePath]).contains("Error")
    }

    var codeSigningIdentity: String? {
        let lines = runCMD(app: "/usr/bin/codesign", args: ["-dvvv", bundlePath]).split(separator: "\n")
        for line in lines {
            if line.hasPrefix("Authority=") {
                return String(line.dropFirst(10))
            }
        }
        return nil
    }

    static func appVersion(path: String, key: String = "CFBundleShortVersionString") -> String? {
        let plist = "\(path)/Contents/Info.plist"
        guard let dictionary = NSDictionary(contentsOfFile: plist) else {
            return nil
        }
        return dictionary.value(forKey: key) as? String
    }

    var icon: NSImage? {
        if let appPath = URL(string: path.string)?.path {
            return NSWorkspace.shared.icon(forFile: appPath)
        }

        if let iconName = infoDictionary?["CFBundleIconFile"] as? String {
            return NSImage(byReferencing: path.join("Contents").join("Resources").join(iconName).url)
        }

        return nil
    }
}

func runCMD(app: String, args: [String]) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = args
    task.launchPath = app
    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    return output
}
