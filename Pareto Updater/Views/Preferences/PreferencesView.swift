//
//  PreferencesView.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import AppKit
import Defaults
import Foundation
import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var appStore: AppBundles
    @State var selected: Tabs
    @Default(.showBeta) var showBeta

    enum Tabs: Hashable {
        case general, about, apps, license
    }

    var body: some View {
        TabView(selection: $selected) {
            GeneralView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)

            AppsView().environmentObject(appStore)
                .tabItem {
                    Label("Apps", systemImage: "app.badge")
                }
                .tag(Tabs.apps)

            LicenseView()
                .tabItem {
                    Label("License", systemImage: "rectangle.badge.person.crop")
                }
                .tag(Tabs.license)
            AboutView().environmentObject(appStore)
                .tabItem {
                    Label("About", systemImage: "info")
                }
                .tag(Tabs.about)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreferencesView(selected: PreferencesView.Tabs.general)
        }
    }
}
