//
//  Defaults.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Defaults
import Foundation

extension Defaults.Keys {
    static let hideWhenNoUpdates = Key<Bool>("hideWhenNoUpdates", default: false)
    static let checkForUpdatesRecentOnly = Key<Bool>("checkForUpdatesRecentOnly", default: true)
}
