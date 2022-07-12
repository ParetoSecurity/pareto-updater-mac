//
//  ContentView.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import Defaults
import SwiftUI

struct AppInstall: View {
    @EnvironmentObject var viewModel: AppBundles
    @Default(.showBeta) var showBeta
    var body: some View {
        VStack {
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
                List(viewModel.apps) { app in
                    AppRow(app: app, showActions: false)
                }.frame(minWidth: 240, minHeight: 120, maxHeight: 200)
            }
            if showBeta {
                Text("viewModel.updating \(viewModel.updating.description)")
                Text("viewModel.installing \(viewModel.workInstall.description)")
            }
            Button {
                viewModel.installAll()

            } label: {
                Text("Download and install apps").font(.subheadline)
            }
            .help("Download and update all")
            .disabled(viewModel.updating || viewModel.workInstall)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 15)
        .frame(minWidth: 240)
    }
}
