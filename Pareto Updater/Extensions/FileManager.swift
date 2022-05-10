//
//  FileManager.swift
//  Pareto Updater
//
//  Created by Janez Troha on 20/04/2022.
//

import Foundation

public extension FileManager {
    /// Create a random directory under the temporary directory and return the URL
    func randomTemporaryDirectory(forUUID uuid: UUID) throws -> URL {
        let folder = temporaryDirectory.appendingPathComponent(uuid.uuidString)

        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)

        return folder
    }
}
