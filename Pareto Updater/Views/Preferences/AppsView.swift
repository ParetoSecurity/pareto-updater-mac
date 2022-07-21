//
//  GeneralPreferences.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Foundation
import LaunchAtLogin
import SwiftUI

struct AppsView: View {
    @EnvironmentObject var viewModel: AppBundles

    func copy() {
        var logs = [String]()
        for app in viewModel.installedApps {
            logs.append("\(app.appMarketingName), \(app.help), \(app.latestURL.absoluteString)")
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(logs.joined(separator: "\n"), forType: .string)
    }

    func share() {
        let bundles = viewModel.installedApps.map { app in
            app.appBundle
        }.joined(separator: ",")

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("paretoupdater://install?bundles=\(bundles)", forType: .string)
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
                List {
                    ForEach(viewModel.installedApps) { app in
                        AppRow(app: app, viewModel: viewModel, onUpdate: nil, showActions: false)
                    }
                }.frame(minHeight: 280)
            }
        }
        .frame(width: 350)
        .padding(25)
        .onAppear {
            DispatchQueue.global(qos: .userInteractive).async {
                viewModel.fetchData()
            }
        }.contextMenu(ContextMenu(menuItems: {
            Button("Copy app list", action: copy)
            Button("Share apps", action: share)
        }))
    }
}
