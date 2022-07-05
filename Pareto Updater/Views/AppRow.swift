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
    @ObservedObject var app: AppUpdater
    var onUpdate: (() -> Void)?

    var body: some View {
        HStack {
            if let appIcon = app.icon {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
            } else {
                Image(systemName: "app.dashed")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
            }
            VStack(alignment: .leading) {
                Text(app.appMarketingName)
                    .font(.body)
                switch app.status {
                case .DownloadingUpdate:
                    ProgressView(value: app.fractionCompleted).frame(height: 1.0)
                case .InstallingUpdate:
                    Text("Installing ...").font(.footnote)
                default:
                    Text(app.help)
                        .font(.footnote)
                }
            }

            Spacer()
            switch app.status {
            case .GatheringInfo:
                ProgressView().frame(width: 15.0, height: 15.0)
                    .scaleEffect(x: 0.5, y: 0.5, anchor: .center).padding(5)
            case .DownloadingUpdate:
                Spacer()
            case .InstallingUpdate:
                Spacer()
            default:
                if app.updatable {
                    if onUpdate != nil {
                        Button {
                            onUpdate?()
                        }
                    label: {
                            Image(systemName: "arrow.down.app.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 15)
                        }
                        .buttonStyle(ClipButton())
                        .help("Update \(app.appMarketingName) to \(app.latestVersionCached)")
                    } else {
                        Image(systemName: "arrow.down.app.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 15)
                    }

                } else {
                    Image(systemName: "checkmark.square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 15
                        ).foregroundColor(.secondary)
                }
            }
        }
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
                AppRow(app: AppFirefox.sharedInstance, onUpdate: {})
            }
        }
    }
#endif
