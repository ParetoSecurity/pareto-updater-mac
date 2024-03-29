//
//  AppCast.swift
//  Pareto Updater
//
//  Created by Janez Troha on 01/07/2022.
//

import Combine
import Foundation
import XMLCoder

struct Enclosure: Codable, DynamicNodeEncoding {
    static func nodeEncoding(for key: CodingKey) -> XMLCoder.XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.url:
            return .attribute
        case CodingKeys.shortVersionString:
            return .attribute
        default:
            return .element
        }
    }

    let url: String
    let shortVersionString: String?
    let version: String?

    enum CodingKeys: String, CodingKey {
        case url
        case shortVersionString = "sparkle:shortVersionString"
        case version = "sparkle:version"
    }
}

struct Item: Codable {
    let title: String?
    let pubDate: String?
    let sparkleVersion: String?
    let shortVersionString: String?
    let enclosure: Enclosure

    enum CodingKeys: String, CodingKey {
        case title
        case pubDate
        case enclosure
        case shortVersionString
        case sparkleVersion = "version"
    }

    var version: String {
        if let ver = shortVersionString, !ver.isEmpty, ver.contains(".") {
            return ver.versionNormalize
        }

        if let ver = enclosure.shortVersionString, !ver.isEmpty, ver.contains(".") {
            return ver.versionNormalize
        }
        if let ver = enclosure.version, !ver.isEmpty, ver.contains(".") {
            return ver.versionNormalize
        }

        // inlined out of spec version
        if let ver = sparkleVersion, !ver.isEmpty, ver.contains(".") {
            return ver.versionNormalize
        }
        return "0.0.0"
    }
}

struct Channel: Codable {
    let link: String?
    let title: String?
    let item: [Item]
}

struct RSS: Codable {
    let channel: Channel
}

class AppCast {
    var version: String = ""
    var url: String = ""

    init(data: Data) {
        let decoder = XMLDecoder()
        decoder.shouldProcessNamespaces = true
        let decoded = try? decoder.decode(RSS.self, from: data)
        let latest = decoded?.channel.item.sorted(by: { lhs, rhs in
            lhs.version.versionCompare(rhs.version) == .orderedDescending
        }).first
        version = latest?.version ?? ""
        url = latest?.enclosure.url ?? ""
    }
}
