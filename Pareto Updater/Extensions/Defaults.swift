//
//  Defaults.swift
//  Pareto Updater
//
//  Created by Janez Troha on 27/04/2022.
//

import Defaults
import Foundation

enum ReportingRoles: String, Defaults.Serializable {
    case free
    case team
    case personal
}

extension Defaults.Keys {
    static let hideWhenNoUpdates = Key<Bool>("hideWhenNoUpdates", default: false)
    static let checkForUpdatesRecentOnly = Key<Bool>("checkForUpdatesRecentOnly", default: true)

    // self-update
    static let showBeta = Key<Bool>("showBeta", default: false)
    static let betaChannel = Key<Bool>("betaChannel", default: false)
    static let machineUUID = Key<String>("machineUUID", default: Constants.getSystemUUID() ?? UUID().uuidString)

    // License
    static let license = Key<String>("license", default: "")
    static let reportingRole = Key<ReportingRoles>("reportingRole", default: .free)

    // Teams
    static let userID = Key<String>("userID", default: "")
    static let userEmail = Key<String>("userEmail", default: "")
    static let isTeamOwner = Key<Bool>("isTeamOwner", default: false)
    static let teamID = Key<String>("teamID", default: "")
    static let teamAuth = Key<String>("teamAuth", default: "")
}

public extension Defaults.Serializable where Self: Codable {
    static var bridge: Defaults.TopLevelCodableBridge<Self> { Defaults.TopLevelCodableBridge() }
}

public extension Defaults.Serializable where Self: Codable & NSSecureCoding {
    static var bridge: Defaults.CodableNSSecureCodingBridge<Self> { Defaults.CodableNSSecureCodingBridge() }
}

public extension Defaults.Serializable where Self: Codable & NSSecureCoding & Defaults.PreferNSSecureCoding {
    static var bridge: Defaults.NSSecureCodingBridge<Self> { Defaults.NSSecureCodingBridge() }
}

public extension Defaults.Serializable where Self: Codable & RawRepresentable {
    static var bridge: Defaults.RawRepresentableCodableBridge<Self> { Defaults.RawRepresentableCodableBridge() }
}

public extension Defaults.Serializable where Self: Codable & RawRepresentable & Defaults.PreferRawRepresentable {
    static var bridge: Defaults.RawRepresentableBridge<Self> { Defaults.RawRepresentableBridge() }
}

public extension Defaults.Serializable where Self: RawRepresentable {
    static var bridge: Defaults.RawRepresentableBridge<Self> { Defaults.RawRepresentableBridge() }
}

public extension Defaults.Serializable where Self: NSSecureCoding {
    static var bridge: Defaults.NSSecureCodingBridge<Self> { Defaults.NSSecureCodingBridge() }
}

public extension Defaults.CollectionSerializable where Element: Defaults.Serializable {
    static var bridge: Defaults.CollectionBridge<Self> { Defaults.CollectionBridge() }
}

public extension Defaults.SetAlgebraSerializable where Element: Defaults.Serializable & Hashable {
    static var bridge: Defaults.SetAlgebraBridge<Self> { Defaults.SetAlgebraBridge() }
}
