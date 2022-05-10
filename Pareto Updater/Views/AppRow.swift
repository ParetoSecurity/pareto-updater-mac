//
//  AppRow.swift
//  Pareto Updater
//
//  Created by Janez Troha on 19/04/2022.
//

import AppKit
import Combine
import Foundation
import os.log
import SwiftUI

struct AppRow: View {
    var app: AppUpdater

    var body: some View {
        HStack {
            if app.isInstalled {
                Image(nsImage: app.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 21)
            } else {
                Image(systemName: "app.dashed")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 21)
            }

            Text(app.appMarketingName)
                .font(.body)
                .help(app.help)
            Spacer()
            if app.fetching {
                if app.fractionCompleted > 0 {
                    ProgressView(value: app.fractionCompleted).frame(width: 18.0, height: 18.0)
                        .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
                } else {
                    ProgressView().frame(width: 18.0, height: 18.0)
                        .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
                }

            } else {
                if app.updatable {
                    Button { app.updateApp { _ in
                        app.updatable = false
                    }} label: {
                        Image(systemName: "arrow.down.to.line.compact")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 13
                            ).foregroundColor(.white)
                    }.buttonStyle(PlainButtonStyle()).help("Update app")
                } else {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 18
                        ).foregroundColor(.green)
                }
            }

        }.padding(0)
    }
}

#if DEBUG
    struct StatefulPreviewWrapper<Fetching, Updatable, Content: View>: View {
        @State var fetching: Fetching
        @State var updatable: Updatable

        var content: (Binding<Fetching>, Binding<Updatable>) -> Content

        var body: some View {
            content($fetching, $updatable)
        }

        init(_ fetching: Fetching, _ updatable: Updatable, content: @escaping (Binding<Fetching>, Binding<Updatable>) -> Content) {
            _fetching = State(wrappedValue: fetching)
            _updatable = State(wrappedValue: updatable)
            self.content = content
        }
    }

    struct AppRow_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                AppRow(app: AppSlack.sharedInstance)
            }
        }
    }
#endif
