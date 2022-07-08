//
//  FileManager.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Foundation

extension FileManager {
    func unzip(_ url: URL) -> URL {
        let proc = Process()
        if #available(OSX 10.13, *) {
            proc.currentDirectoryURL = url.deletingLastPathComponent()
        } else {
            proc.currentDirectoryPath = url.deletingLastPathComponent().path
        }

        if url.pathExtension == "zip" {
            proc.launchPath = "/usr/bin/unzip"
            proc.arguments = [url.path]
        } else {
            proc.launchPath = "/usr/bin/tar"
            proc.arguments = ["xf", url.path]
        }

        func findApp() throws -> URL? {
            let files = try FileManager.default.contentsOfDirectory(at: url.deletingLastPathComponent(), includingPropertiesForKeys: [.isDirectoryKey], options: .skipsSubdirectoryDescendants)
            for url in files {
                guard url.pathExtension == "app" else { continue }
                guard let foo = try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory, foo else { continue }
                return url
            }
            return nil
        }
        proc.launch()
        proc.waitUntilExit()
        return try! findApp()!
    }
}
