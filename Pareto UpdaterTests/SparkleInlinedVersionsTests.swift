//
//  Pareto_UpdaterTests.swift
//  Pareto UpdaterTests
//
//  Created by Janez Troha on 14/04/2022.
//

@testable import Pareto_Updater
import XCTest
import XMLCoder

private let sourceXMLwrongversions = """
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
<channel>
<title>WiFiSpoof Changelog</title>
<link>https://sweetpproductions.com/products/wifispoof/appcast.xml</link>
<description>Most recent changes with links to updates.</description>
<language>en</language>
<item>
<title>Version 3.8.4.1</title>
<sparkle:releaseNotesLink>https://sweetpproductions.com/products/wifispoof3/updates.htm</sparkle:releaseNotesLink>
<sparkle:version>3.8.4.1</sparkle:version>
<pubDate>Jul 21 2022 16:10:11 +0100</pubDate>
<sparkle:informationalUpdate>
<sparkle:version>3.7.0.1</sparkle:version>
</sparkle:informationalUpdate>
<link>https://sweetpproductions.com/products/wifispoof3/updates.htm</link>
<enclosure url="https://sweetpproductions.com/products/wifispoof3/WiFiSpoof3.dmg" type="application/octet-stream" sparkle:edSignature="iVreKy2VfezdGPmD6lGBBC22GuhgmtARvnNmWxSx0TcQITXWlR+dSRQrqDq3RuSG23XVe1Dn+iFecTbokkDvDQ==" length="3243742"/>
</item>
</channel>
</rss>
"""

class SparkeInlinedersionsTests: XCTestCase {
    func testGetCorrectVersion() throws {
        let app = AppCast(data: Data(sourceXMLwrongversions.utf8))
        assert(app.version == "3.8.4.1")
    }
}
