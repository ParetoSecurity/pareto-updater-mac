//
//  AppCast.swift
//  Pareto Updater
//
//  Created by Janez Troha on 01/07/2022.
//

import Combine
import Foundation
import XMLCoder
import Version


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
    
    var version: String  {
        if let ver = self.shortVersionString, !ver.isEmpty {
            return ver
        }

        if let ver = self.enclosure.shortVersionString, !ver.isEmpty {
            return ver
        }
        if let ver = self.enclosure.version, !ver.isEmpty {
            return ver
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
        let latest = decoded?.channel.item.first
        version = latest?.version ?? ""
        url = latest?.enclosure.url ?? ""
    }
}
