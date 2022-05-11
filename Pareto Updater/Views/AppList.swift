//
//  ContentView.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import SwiftUI

struct AppList: View {
    @StateObject var viewModel: AppBundles

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Pareto Updater").font(.title3)
                Spacer()

                Button {
                    viewModel.updateAll()

                } label: {
                    Image(systemName: "arrow.down.square").resizable().aspectRatio(contentMode: .fit)
                        .frame(height: 15
                        )
                }.buttonStyle(.plain).disabled(viewModel.fetching)
                    .help("Download and update all").disabled(!viewModel.haveUpdatableApps || viewModel.fetching)

                Button {
                    viewModel.fetchData()

                } label: {
                    Image(systemName: "arrow.clockwise").resizable().aspectRatio(contentMode: .fit)
                        .frame(height: 15
                        )
                }.buttonStyle(.plain).disabled(viewModel.fetching)
                    .help("Refresh the status of the apps")

                Button {} label: {
                    Image(systemName: "gearshape").resizable().aspectRatio(contentMode: .fit)
                        .frame(height: 15
                        )
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

            if viewModel.haveUpdatableApps {
                Text("Available Updates").font(.caption2)
                List(viewModel.updatableApps) { app in
                    AppRow(app: app, onUpdate: {
                        viewModel.fetching = true
                        app.updateApp { _ in
                            viewModel.fetching = false
                            viewModel.fetchData()
                        }
                    })
                }
                .padding(0)
            } else {
                if viewModel.fetching {
                    HStack(alignment: .center) {
                        ProgressView().frame(width: 18.0, height: 18.0)
                            .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
                        Text("Checking for updates").font(.body).multilineTextAlignment(.center).padding(5)
                    }
                } else {
                    HStack(alignment: .center) {
                        Text("All Apps are up to date!").font(.body).multilineTextAlignment(.center).padding(5)
                    }
                }
            }

        }.padding(10).onAppear {
            viewModel.fetchData()
        }.frame(minHeight: viewModel.haveUpdatableApps ? 200 : 50)
    }
}

struct AppList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppList(viewModel: AppBundles())
        }
    }
}
