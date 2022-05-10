//
//  ContentView.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import SwiftUI

struct AppList: View {
    @StateObject fileprivate var viewModel = AppBundles()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Pareto Updater").font(.title3)
                Spacer()

                Button {
                    viewModel.fetchData()

                } label: {
                    Image(systemName: "arrow.down.to.line.circle")
                }.buttonStyle(PlainButtonStyle()).disabled(viewModel.fetching)
                    .help("Download and update all")

                Button {
                    viewModel.fetchData()

                } label: {
                    Image(systemName: "arrow.clockwise")
                }.buttonStyle(PlainButtonStyle()).disabled(viewModel.fetching)
                    .help("Refresh the status of the apps")

                Button {} label: {
                    Image(systemName: "gearshape")
                }.buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button("Preferences", action: {
                            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                            NSApp.activate(ignoringOtherApps: true)
                        })
                        Button("Quit", action: {
                            NSApplication.shared.terminate(self)
                        })
                    }
            }
            Spacer(minLength: 15)
            Text("Available Updates").font(.caption2)
            List(viewModel.apps) { app in
                if viewModel.fetching {
                    AppRow(app: app).disabled(viewModel.fetching)
                } else {
                    if app.updatable {
                        AppRow(app: app)
                    } else {
                        AppRow(app: app)
                    }
                }
            }
            .onAppear {
                viewModel.fetchData()
            }
            .padding(0)
        }.padding(10)
    }
}

struct AppList_Previews: PreviewProvider {
    static var previews: some View {
        AppList()
    }
}
