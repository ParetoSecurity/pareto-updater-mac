//
//  AboutView.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Defaults
import Foundation
import SwiftUI

struct AboutView: View {
    @State private var isLoading = false
    @State private var status = UpdateStates.Checking
    @State private var konami = 0
    @Default(.showBeta) var showBeta
    @EnvironmentObject var viewModel: AppBundles

    enum UpdateStates: String {
        case Checking = "Checking for updates"
        case NewVersion = "New version found"
        case Installing = "Installing new update"
        case Updated = "App is up to date"
        case Failed = "Failed to update, download manually"
    }

    var body: some View {
        HStack {
            Image("Logo").resizable()
                .aspectRatio(contentMode: .fit).frame(maxWidth: 96).padding(10).onTapGesture {
                    konami += 1
                    if konami >= 3 {
                        showBeta.toggle()
                        konami = 0
                        if showBeta {
                            let alert = NSAlert()
                            alert.messageText = "You are now part of a secret society seeing somewhat mysterious things."
                            alert.alertStyle = NSAlert.Style.informational
                            alert.addButton(withTitle: "Let me in")
                            alert.runModal()
                        }
                    }
                }

            VStack(alignment: .leading) {
                Link("Pareto Updater",
                     destination: URL(string: "https://paretosecurity.com/updater")!).font(.title)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Version: \(Constants.appVersion) - \(Constants.buildVersion)")
                    if showBeta {
                        Text("\(Constants.utmSource)")
                    }

                    HStack(spacing: 10) {
                        if status == UpdateStates.Failed {
                            HStack(spacing: 0) {
                                Text("Failed to update ")
                                Link("download manually",
                                     destination: URL(string: "https://github.com/paretosecurity/pareto-updater-mac/releases/latest/download/ParetoUpdater.dmg")!)
                            }
                        } else {
                            Text(status.rawValue)
                        }

                        if self.isLoading {
                            ProgressView().frame(width: 5.0, height: 5.0)
                                .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
                        }
                    }
                }

                HStack(spacing: 0) {
                    Text("We’d love to ")
                    Link("hear from you!",
                         destination: URL(string: "https://niteo.co/contact")!)
                }

                HStack(spacing: 0) {
                    Text("Made with ❤️ at ")
                    Link("Niteo",
                         destination: URL(string: "https://niteo.co/about")!)
                }
            }.padding(.leading, 20.0)

        }.frame(width: 380, height: 180).onAppear(perform: fetch)
    }

    private func fetch() {
        if viewModel.workInstall || viewModel.updating || viewModel.installingApps {
            return
        }

        #if !DEBUG
            DispatchQueue.global(qos: .userInitiated).async {
                isLoading = true
                status = UpdateStates.Checking
                let currentVersion = Bundle.main.version
                if let release = try? AppDelegate.updater.getLatestRelease(allowPrereleases: false) {
                    isLoading = false
                    if currentVersion < release.version {
                        status = UpdateStates.NewVersion
                        if let zipURL = release.assets.filter({ $0.browserDownloadURL.path.hasSuffix(".zip") }).first {
                            status = UpdateStates.Installing
                            isLoading = true

                            let done = AppDelegate.updater.downloadAndUpdate(withAsset: zipURL)
                            if !done {
                                status = UpdateStates.Failed
                                isLoading = false
                            }

                        } else {
                            status = UpdateStates.Updated
                            isLoading = false
                        }
                    } else {
                        status = UpdateStates.Updated
                        isLoading = false
                    }
                } else {
                    status = UpdateStates.Updated
                    isLoading = false
                }
            }
        #else
            status = UpdateStates.Updated
        #endif
    }
}

struct AboutSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
