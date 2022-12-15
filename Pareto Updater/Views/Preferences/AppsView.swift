//
//  GeneralPreferences.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Foundation
import LaunchAtLogin
import os.log
import SwiftUI

struct AppsView: View {
    @EnvironmentObject var viewModel: AppBundles

    func copy() {
        var logs = [String]()
        logs.append("Name, Bundle, Version")
        for app in viewModel.installedApps {
            logs.append("\(app.appMarketingName), \(app.appBundle), \(app.help)")
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(logs.joined(separator: "\n"), forType: .string)
    }

    func share() {
        let bundles = viewModel.installedApps.filter { app in
            !app.fromAppStore
        }.map { app in
            app.appBundle
        }.joined(separator: ",")
        NSWorkspace.shared.open(URL(string: "https://paretosecurity.com/bulk-install#\(bundles)")!)
    }

    func clearCache() {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let fileManager = FileManager.default
                let filePaths = try fileManager.contentsOfDirectory(atPath: Constants.cacheFolder.path)
                for filePath in filePaths {
                    if filePath.hasSuffix(".dmg") || filePath.hasSuffix(".zip") || filePath.hasSuffix(".pkg") {
                        try fileManager.removeItem(atPath: Constants.cacheFolder.appendingPathComponent(filePath).path)
                    }
                }
            } catch {
                os_log("Could not clear temp folder: %{public}s", error.localizedDescription)
            }
            try? Constants.versionStorage.removeAll()
            viewModel.fetchData()
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.updating {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Fetching Versions").font(.body)
                    ProgressView()
                        .frame(width: 18.0, height: 18.0)
                        .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
                    Spacer()
                }
            } else {
                List(viewModel.installedApps) {
                    AppRowConfig(app: $0, viewModel: viewModel, onUpdate: nil, showActions: false)

                }.frame(minHeight: 280).navigationTitle("Detected Apps")

                HStack {
                    Spacer()
                    Menu {
                        Button("Copy app list", action: copy)
                        Button("Share installed apps", action: share)
                        Button("Clear cache", action: clearCache)
                    } label: {
                        Label("...", systemImage: "link")
                    }.menuStyle(.borderlessButton).frame(width: 25).fixedSize()
                }
            }
        }
        .frame(width: 350)
        .padding(25)
        .onAppear {
            DispatchQueue.global(qos: .userInteractive).async {
                viewModel.fetchData()
            }
        }
    }
}
