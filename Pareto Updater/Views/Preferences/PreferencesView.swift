//
//  PrefrencesView.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import AppKit
import Foundation
import SwiftUI

struct PreferencesView: View {
    @State var selected: Tabs
    enum Tabs: Hashable {
        case general, about
    }

    var body: some View {
        TabView(selection: $selected) {
            GeneralView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            AboutView()
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
