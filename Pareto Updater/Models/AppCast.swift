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
    let shortVersionString: String?
    let enclosure: Enclosure

    enum CodingKeys: String, CodingKey {
        case title
        case pubDate
        case enclosure
        case shortVersionString
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
        version = "0.0.0"
        if let ve = decoded?.channel.item.first?.enclosure.version, !ve.isEmpty {
            version = ve
        }
        if let ve = decoded?.channel.item.first?.enclosure.shortVersionString, !ve.isEmpty {
            version = ve
        }
        if let ve = decoded?.channel.item.first?.shortVersionString, !ve.isEmpty {
            version = ve
        }
        url = decoded?.channel.item.first?.enclosure.url ?? ""
    }
}
