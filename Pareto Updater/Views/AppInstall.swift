//
//  ContentView.swift
//  Pareto Updater
//
//  Created by Janez Troha on 14/04/2022.
//

import SwiftUI

struct AppInstall: View {
    @StateObject var viewModel: AppBundles

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                ForEach(viewModel.apps) { app in
                    AppRow(app: app, onUpdate: {
                        viewModel.updateApp(withApp: app)
                    })
                }
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 15)
        .frame(minWidth: 240)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

#if DEBUG

    class AppBundlesAppInstallFake: AppBundles {
        convenience init(updating: Bool) {
            self.init()
            self.updating = updating
        }

        convenience init(installing: Bool) {
            self.init()
            self.installing = installing
        }
    }

    struct AppInstall_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                AppList(viewModel: AppBundlesAppInstallFake(updating: true))
                AppList(viewModel: AppBundlesAppInstallFake(installing: true))
            }
        }
    }
#endif
