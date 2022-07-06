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

let sourceXML4 = """

<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
    <channel>

                       <item>
            <sparkle:minimumSystemVersion>10.13.0</sparkle:minimumSystemVersion>
            <sparkle:releaseNotesLink>
                https://updates.folivora.ai/needs_manual_upgrade.html
            </sparkle:releaseNotesLink>
            <BTTPaidUpgradeCheckEnabled>false</BTTPaidUpgradeCheckEnabled>

            <pubDate>Mon, 03 Aug 2020 16:25:35 +0200</pubDate>
            <hashes>A73DFC1D8E3BD27CD1EE79D86D971D2956287F4D::D57D7B1F897AD24351BD7DF58C230F510C3C4AE5::d2d36e8c0ec63783bf1163eb3e570da9::FB5F79BF2B8829F11A87D1D30171808374EFE533::62B7890BDEA94DC72B2246F920DD00C7A2F7F2B8::98995FA9C57D959FD08B130ABBA020E6CE8620FF::C422AA08A78995C085B515CA4C57D3DF9919D2D3::9D7E11B98A91A3CFC7B601D056E05F5FB430EC7E::84B1AB4B40CAFB6B58D8B89DEC6C6804A97C785D::B38F6CD317E3E2DAEFD1CEF64801D9A91C425D9C::7A4282DE2E9840A66B6A39C713900DA870AEF8F2::3965978617BC7291613927E4D611D7DCC050F569::63D907FEB7284BD6DC8A3588A363F31920B28133::191052552388D34B9882530440FDF80DA3B61AEA::C5CBD6266463132A87948E735B82B0AA97976678::EBA215BA2B337685BF1827BFD018D91F129A0555::88922BDB7630C269FE117FC6FFAD10BE9D38D81C::127D9BB93A1E335A30C18645BE32C6FA83A87C49::0106D0EB2699C8BD82B8D0FE462E8EF3E625A3AB::4248B4705BFCED43FD9C887BCA44A4DB9971D847::C8DCA529208BFE6E9C659A49F947F9ACEF5F3C2AC::71B9D233CE39FA7773249C7D8BD3CEE083E7D340::951A9FE8DABC188A13807F6D8D5E1630CB22775F::F8602A28B9A12C01C01CCB7BD5BF0F33B690F451::74CEC8DDEA2CDB6806FAEE0F56F2497C2F89E809::176342EE82A2AA31381181C0BEDD094E1EC8858E::::</hashes>
<enclosure
                url="https://folivora.ai/releases/doesnotexist.zip"
                sparkle:version="1631"
                sparkle:shortVersionString="3.401"
                 type="application/octet-stream"
                length="18859402"
                sparkle:dsaSignature="MC0CFD5gUc5iOrUTmJt9cn6MBtT0sqdmAhUAvQG9bOXqPkG7nmGpLYTSCud7Yqs="
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

    func testAppCast4() throws {
        let app = AppCast(data: Data(sourceXML4.utf8))
        assert(app.version == "")
        assert(app.url == "")
    }

    func testAppNibble() throws {
        assert("1.1.0".versionCompare("1.0.0") == .orderedDescending)
        assert("1.1.0-3".versionCompare("1.1.0-2") == .orderedDescending)
    }
}
