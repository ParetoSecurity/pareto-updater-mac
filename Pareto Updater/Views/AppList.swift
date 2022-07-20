//
//  ContentView.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import SwiftUI

struct AppList: View {
    @EnvironmentObject var viewModel: AppBundles

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Pareto Updater").font(.title3)
                Spacer()

                Button {
                    viewModel.updateAll()

                } label: {
                    Image(systemName: "arrow.down.square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 13)
                }
                .buttonStyle(ClipButton())
                .help("Download and update all")
                .disabled(!viewModel.haveUpdatableApps || viewModel.updating || viewModel.workInstall)

                Button {
                    DispatchQueue.global(qos: .userInteractive).async {
                        viewModel.fetchData()
                    }

                } label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 13)
                }
                .buttonStyle(ClipButton())
                .disabled(viewModel.updating || viewModel.workInstall)
                .help("Refresh the status of the apps")

                Button {
                    if #available(macOS 13.0, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Image(systemName: "gearshape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 13)
                }.buttonStyle(ClipButton())
            }

            if viewModel.haveUpdatableApps && !viewModel.updating {
                Text("Available Updates").font(.caption2)
//                if #available(macOS 13, *) {
//                    ScrollView {
//                        VStack(alignment: .leading) {
//                            ForEach(viewModel.updatableApps) { app in
//                                AppRow(app: app, onUpdate: {
//                                    viewModel.updateApp(withApp: app)
//                                })
//                            }
//                        }
//                    }.frame(minHeight: CGFloat(min(viewModel.updatableApps.count, 3)) * 40)
//                } else {
                VStack(alignment: .leading) {
                    ForEach(viewModel.updatableApps) { app in
                        AppRow(app: app, viewModel: viewModel, onUpdate: {
                            viewModel.updateApp(withApp: app)
                        })
                    }
                }
                // }
            } else {
                Group {
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
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Apps Are Updated").font(.body)
                            Spacer()
                        }
                    }
                }.frame(minHeight: 20.0)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
        .frame(minWidth: 240)
    }
}
