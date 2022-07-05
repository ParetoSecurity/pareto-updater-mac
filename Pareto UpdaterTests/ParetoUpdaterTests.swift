//
//  Pareto_UpdaterTests.swift
//  Pareto UpdaterTests
//
//  Created by Janez Troha on 14/04/2022.
//

@testable import Pareto_Updater
import XCTest
import XMLCoder

let sourceXML1 = """
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

let sourceXML2 = """
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
<channel>
<title>Maccy</title>
<link>https://raw.githubusercontent.com/p0deje/Maccy/master/appcast.xml</link>
<description>Most recent changes with links to updates.</description>
<language>en</language>
<item>
<title>0.22.2</title>
<description>
<![CDATA[
    <ul>
    <li>Improved the header and search field horizontal padding on macOS 11+.</li>
    <li>Fixed an issue when the search field would select all the entered text upon finding no results.</li>
    <li>Moved storage preferences to a separate tab.</li>
    <li>Fixed pasting the wrong item on the App Store version of Microsoft Word.</li>
    </ul>
]]>
</description>
<pubDate>2022-02-11</pubDate>
<releaseNotesLink>https://github.com/p0deje/Maccy/releases/tag/0.22.2</releaseNotesLink>
<sparkle:minimumSystemVersion>10.14</sparkle:minimumSystemVersion>
<enclosure
url="https://github.com/p0deje/Maccy/releases/download/0.22.2/Maccy.app.zip"
sparkle:version="11"
sparkle:shortVersionString="0.22.2"
length="0"
type="application/octet-stream"
/>
</item>
</channel>
</rss>
"""

let sourceXML3 = """
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
<channel>
<item>
<title>1.3.0</title>
<pubDate>Thu, 02 Jun 2022 00:16:21 -0400</pubDate>
<sparkle:version>132</sparkle:version>
<sparkle:shortVersionString>1.3.0</sparkle:shortVersionString>
<sparkle:minimumSystemVersion>10.11</sparkle:minimumSystemVersion>
<sparkle:releaseNotesLink>https://www.iina.io/release-note/1.3.0.html</sparkle:releaseNotesLink>
<enclosure url="https://dl-portal.iina.io/IINA.v1.3.0.dmg" length="76967556" type="application/octet-stream" sparkle:edSignature="NvQug0B7L5J6IxUwVZnmn6CF8SJXHP7nVQ54zn77/Y+OkEZi7nOYr4sGlvlaTTQfVqJNRxd5CQUiE3w+b1SLAA==" sparkle:dsaSignature="MC0CFQDNvWSHsbYrhnD7zXqiA4DW7XhGMAIUaStEum43BRe7gG7fR4FqCj2ANf0="/>
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
        let app = AppCast(data: Data(sourceXML1.utf8))
        assert(app.version == "2.17")
        assert(app.url == "https://apps.shinynode.com/apps/update/image2icon_943.zip")
    }

    func testAppCast2() throws {
        let app = AppCast(data: Data(sourceXML2.utf8))
        assert(app.version == "0.22.2")
        assert(app.url == "https://github.com/p0deje/Maccy/releases/download/0.22.2/Maccy.app.zip")
    }

    func testAppCast3() throws {
        let app = AppCast(data: Data(sourceXML3.utf8))
        assert(app.version == "1.3.0")
        assert(app.url == "https://dl-portal.iina.io/IINA.v1.3.0.dmg")
    }

    func testAppNibble() throws {
        let app = AppUpdater()
        assert(app.nibbles(version: "1.1.1") == 70)
        assert(app.nibbles(version: "1.1.1.1") == 150)
        assert(app.nibbles(version: "17.1") == 350)
        assert(app.nibbles(version: "17.1.1") == 710)
    }

    func testAppNibbleSubversion() throws {
        let app = AppUpdater()
        assert(app.nibbles(version: "17.1-1alpha") == 380)
        assert(app.nibbles(version: "17.1-2alpha") == 390)
        assert(app.nibbles(version: "1.1.1-2") == 110)
        assert(app.nibbles(version: "1.1.1-3") == 120)
        assert(app.nibbles(version: "17.1-1") == 380)
    }
}
