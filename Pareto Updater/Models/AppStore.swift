//
//  AppStore.swift
//  Pareto Updater
//
//  Created by Janez Troha on 01/07/2022.
//

import Combine
import Foundation

// MARK: - AppStoreResponse

struct AppStoreResponse: Codable {
    let results: [AppStoreResult]
}

// MARK: - Result

struct AppStoreResult: Codable {
    let trackID: Int
    let version: String

    enum CodingKeys: String, CodingKey {
        case trackID = "trackId"
        case version
    }
}
