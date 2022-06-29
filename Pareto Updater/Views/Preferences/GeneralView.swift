//
//  GeneralPreferences.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Defaults
import Foundation
import LaunchAtLogin
import SwiftUI

struct GeneralView: View {
    @ObservedObject private var atLogin = LaunchAtLogin.observable
    @Default(.hideWhenNoUpdates) var hideWhenNoUpdates
    @Default(.checkForUpdatesRecentOnly) var checkForUpdatesRecentOnly
    @Default(.showBeta) var showBeta
    @Default(.betaChannel) var betaChannel
    var body: some View {
        Form {
            Section(
                footer: Text("To enable continuous monitoring and updating.").font(.footnote)) {
                    VStack(alignment: .leading) {
                        Toggle("Automatically launch on system startup", isOn: $atLogin.isEnabled)
                    }
                }
            Section(
                footer: Text("App is running checks even when the icon is hidden.").font(.footnote)) {
                    VStack(alignment: .leading) {
                        Toggle("Only show in menu bar when the updates are available", isOn: $hideWhenNoUpdates)
                    }
                }
            if showBeta {
                Section(
                    footer: Text("Latest features but potentially bugs to report.").font(.footnote)) {
                        VStack(alignment: .leading) {
                            Toggle("Update app to pre-release builds", isOn: $betaChannel)
                        }
                    }
            }
            Section(
                footer: Text("Only scan for updates for recently used apps.").font(.footnote)) {
                    VStack(alignment: .leading) {
                        Toggle("Update check only for apps used in the last week", isOn: $checkForUpdatesRecentOnly)
                    }
                }
        }

        .frame(width: 350).padding(25)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView()
    }
}
