//
//  Pareto_UpdaterTests.swift
//  Pareto UpdaterTests
//
//  Created by Janez Troha on 14/04/2022.
//

@testable import Pareto_Updater
import XCTest
import XMLCoder

let sourceXML = """
<?xml version="1.0" encoding="utf-8"?>

<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
    <title>image2icon Changelog</title>
        <link>http://apps.shinynode.com/apps/image2icon_appcast.xml</link>
        <description>Most recent changes with links to updates.</description>
        <language>en</language>

<item>
        <title>Version 2.17</title>
                        <pubDate>Aug. 6, 2015, 4:39 p.m.</pubDate>
                        <enclosure
                        url="https://apps.shinynode.com/apps/update/image2icon_943.zip"
                        sparkle:version="587"
                        sparkle:shortVersionString="2.17"
                        type="application/octet-stream"
                        length="20403691"
                        sparkle:dsaSignature="MCwCFFRsy3OgEXquZUvOmsccJD0oKUQsAhRAa1UpfF6BpnpbEXJyh8YbYltdHw=="
                        />
        </item>


        <item>
        <title>Version 1.2.2</title>
                        <pubDate>Oct. 13, 2009, 7:05 p.m.</pubDate>
                        <enclosure
                        url="https://apps.shinynode.com/apps/update/image2icon_1.2.2.zip"
                        sparkle:version="1.2.2"
                        sparkle:shortVersionString="1.2.2"
                        type="application/octet-stream"
                        length=""
                        sparkle:dsaSignature=""
                        />
        </item>

    </channel>
</rss>

"""
class ParetoUpdaterTests: XCTestCase {
    func testCurrentVersion() throws {
        let bundles = AppBundles()
        for app in bundles.apps {
            print(app.currentVersion)
        }
    }

    func testLatestVersion() throws {
        let bundles = AppBundles()
        for app in bundles.apps {
            print(app.latestVersion)
        }
    }

    func testInstall() throws {
        let bundles = AppBundles()
        for app in bundles.customApps {
            app.updateApp { status in
                print(status)
            }
        }
    }

    func testAppCast() throws {
        let app = AppCast(data: Data(sourceXML.utf8))
        assert(app.version == "2.17")
        assert(app.url == "http://apps.shinynode.com/apps/update/image2icon_943.zip")
    }
}
