//
//  Process.swift
//  Pareto Updater
//
//  Created by Janez Troha on 08/07/2022.
//

import Foundation
import os.log

public extension Process {
    static func run(app: String, args: [String]) -> String {
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

    static func runCMDasAdmin(cmd: String) -> Bool {
        let myAppleScript = "do shell script \"\(cmd)\" with administrator privileges"
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: myAppleScript) {
            scriptObject.executeAndReturnError(&error)
            if error != nil {
                os_log("OSA Error: %{public}s", error.debugDescription)
                return false
            }
        }
        return true
    }
}
