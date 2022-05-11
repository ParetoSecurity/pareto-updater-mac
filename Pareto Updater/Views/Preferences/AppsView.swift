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
    @StateObject var viewModel: AppBundles

    var body: some View {
        VStack(alignment: .leading) {
            Text("Installed Apps").font(.caption2)
            List {
                ForEach(viewModel.installedApps) { app in
                    AppRow(app: app, onUpdate: nil)
                }
            }.frame(minHeight: 180)
        }
        .frame(width: 350)
        .padding(25)
    }
}

struct AppsView_Previews: PreviewProvider {
    static var previews: some View {
        AppsView(viewModel: AppBundles())
    }
}
