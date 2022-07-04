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
        ZStack {
            // Moves in from leading out, out to trailing edge.
            Image("menubar")
                .resizable()
                .opacity(0.9)
                .frame(width: 16, height: 16, alignment: .center)

        }.frame(width: 16, height: 16, alignment: .center).padding(.horizontal, 4.0)
            .padding(.vertical, 2.0)
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            MenuBarView().preferredColorScheme($0)
        }
    }
}
