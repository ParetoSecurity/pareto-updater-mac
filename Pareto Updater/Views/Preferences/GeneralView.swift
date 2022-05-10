//
//  GeneralPreferences.swift
//  Pareto Updater
//
//  Created by Janez Troha on 26/04/2022.
//

import Foundation
import LaunchAtLogin
import SwiftUI

struct GeneralView: View {
    @ObservedObject private var atLogin = LaunchAtLogin.observable

    var body: some View {
        Form {
            Section(
                footer: Text("To enable continuous monitoring and updating.").font(.footnote)) {
                    VStack(alignment: .leading) {
                        Toggle("Automatically launch on system startup", isOn: $atLogin.isEnabled)
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
