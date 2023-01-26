//
//  LicenseView.swift
//  LicenseView
//
//  Created by Janez Troha on 10/09/2021.
//

import Defaults
import SwiftUI

struct LicenseView: View {
    @Default(.userEmail) var userEmail
    @Default(.license) var license
    @Default(.showBeta) var showBeta

    func tryLicense() {
        if let lic = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string) {
            if lic.contains("paretoupdater://"), !Constants.Licensed {
                if let url = URL(string: lic) {
                    AppDelegate().processAction(url)
                }
            }
        }
    }

    var body: some View {
        if Constants.Licensed {
            if !Defaults[.teamID].isEmpty {
                VStack(alignment: .leading) {
                    Spacer()
                    Text("The app is licensed under the Teams account.")
                    Spacer()
                }.frame(width: 350, height: 50).padding(25)
            } else {
                VStack(alignment: .leading) {
                    Text("Thanks for purchasing the Personal license. The app is licensed to \(userEmail).")
                    Spacer()
                }.frame(width: 350, height: 50).padding(25)
            }

        } else {
            VStack {
                Text("You are running the free version of the app. Please consider purchasing the Personal lifetime license for unlimited devices!")
                Link("Learn more »",
                     destination: URL(string: "https://paretosecurity.com/updater?utm_source=\(Constants.utmSource)&utm_medium=license-link")!)
            }.frame(width: 350, height: 80).padding(25).onAppear(perform: tryLicense)
        }
    }
}

struct LicenseView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseView()
    }
}
