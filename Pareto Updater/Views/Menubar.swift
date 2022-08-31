//
//  TimerView.swift
//  Work Hours
//
//  Created by Janez Troha on 19/12/2021.
//
import Defaults
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var viewModel: AppBundles

    var body: some View {
        if viewModel.haveUpdatableApps {
            Image("menubar-updates")
                .resizable()
                .opacity(0.9).frame(width: 17, height: 18, alignment: .center)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        } else {
            Image("menubar-idle")
                .resizable()
                .opacity(0.9).frame(width: 17, height: 18, alignment: .center)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            MenuBarView().preferredColorScheme($0).environmentObject(AppBundles())
        }
    }
}
