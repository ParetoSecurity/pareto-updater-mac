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

func appVersion(path: String, key: String = "CFBundleShortVersionString") -> String? {
    let plist = "\(path)/Contents/Info.plist"
    guard let dictionary = NSDictionary(contentsOfFile: plist) else {
        os_log("Failed reading %{public}s", plist)
        return nil
    }
    // print("\(app): \(dictionary as AnyObject)")
    return dictionary.value(forKey: key) as? String
}
