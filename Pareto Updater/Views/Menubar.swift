//
//  TimerView.swift
//  Work Hours
//
//  Created by Janez Troha on 19/12/2021.
//
import Defaults
import SwiftUI

struct MenuBarView: View {
    var body: some View {
        HStack {
            Image("menubar")
                .resizable()
                .opacity(0.9)
        }.frame(width: 21, height: 21, alignment: .center)
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            MenuBarView().preferredColorScheme($0)
        }
    }
}
