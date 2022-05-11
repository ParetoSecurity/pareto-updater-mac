//
//  View.swift
//  Pareto Updater
//
//  Created by Janez Troha on 11/05/2022.
//

import Foundation
import SwiftUI

struct BlinkViewModifier: ViewModifier {
    let duration: Double
    @State private var blinking: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(blinking ? 0.5 : 1)
            .animation(.easeOut(duration: duration).repeatForever())
            .onAppear {
                withAnimation {
                    blinking = true
                }
            }
    }
}

extension View {
    func blinking(duration: Double = 0.45) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
}
