//
//  AppRow.swift
//  Pareto Updater
//
//  Created by Janez Troha on 19/04/2022.
//

import AppKit
import Combine
import Defaults
import Foundation
import os.log
import SwiftUI

struct AppRow: View {
    @ObservedObject var app: AppUpdater
    @ObservedObject var viewModel: AppBundles
    var onUpdate: (() -> Void)?
    @State var showActions: Bool = true
    @Default(.showBeta) var showBeta

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
                if showBeta {
                    Text(app.appBundle)
                        .font(.footnote)
                }
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
                ProgressView().frame(width: 15.0, height: 15.0)
                    .scaleEffect(x: 0.5, y: 0.5, anchor: .center).padding(5)
            case .Failed:
                Image(systemName: "exclamationmark.square")
                    .resizable()
                    .foregroundColor(.red)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 15)
            case .Installed:
                Image(systemName: "checkmark.square")
                    .resizable()
                    .foregroundColor(.green)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 15)
            default:
                if app.hasUpdate {
                    if onUpdate != nil, showActions, !viewModel.workInstall {
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
                        .help("Update \(app.appMarketingName) to \(app.latestVersion)")
                    } else {
                        Image(systemName: "arrow.down.app.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 15)
                    }

                } else {
                    if app.isInstalled {
                        Image(systemName: "checkmark.square")
                            .resizable()
                            .foregroundColor(.secondary)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 15)
                    } else {
                        Image(systemName: "arrow.down.app.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 15)
                    }
                }
            }
        }
    }
}
