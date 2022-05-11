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

                Button {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Image(systemName: "gearshape").resizable().aspectRatio(contentMode: .fit)
                        .frame(height: 15
                        )
                }.buttonStyle(.plain)
            }

            if viewModel.haveUpdatableApps {
                VStack(alignment: .leading) {
                    Text("Available Updates").font(.caption2)
                    ForEach(viewModel.updatableApps) { app in
                        AppRow(app: app, onUpdate: {
                            viewModel.updateApp(withApp: app)
                        })
                    }
                }
            } else {
                Group {
                    if viewModel.fetching {
                        HStack(alignment: .center) {
                            Text("Checking for updates").font(.body)
                            ProgressView().frame(width: 18.0, height: 18.0)
                                .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
                        }
                    } else {
                        HStack(alignment: .center) {
                            Text("All Apps are up to date!").font(.body)
                        }
                    }
                }.frame(minHeight: 20.0)
            }

        }.padding(15).onAppear {
            viewModel.fetchData()
        }
    }
}

struct AppList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppList(viewModel: AppBundles())
        }
    }
}
