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

    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(viewModel.installedApps) { app in
                    AppRow(app: app, onUpdate: nil)
                }
            }.frame(minHeight: 280)
        }
        .frame(width: 350)
        .padding(25)
        .onAppear {
            viewModel.fetchData()
        }.contextMenu(ContextMenu(menuItems: {
            Button("Copy app list", action: copy)
        }))
    }
}
