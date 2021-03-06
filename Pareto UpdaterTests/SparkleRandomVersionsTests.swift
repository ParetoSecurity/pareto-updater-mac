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
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
    <channel>
        <title>QLMarkdown</title>
        <item>
            <title>1.0.15</title>
            <pubDate>lun, 4 apr 2022 23:37:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0.15/QLMarkdown.zip" sparkle:shortVersionString="1.0.15" sparkle:version="40" sparkle:edSignature="1SRvlwl3js7vNPgoiJSn5d+Qt476n1uARCq2o65P9z+cz7UpO4f6MsjOGyiPVAhY+R0xSwKiYNFy2fPNLxeFAA==" length="17267050" />
            <description><![CDATA[
<h2>1.0.15 (40)</h2>
<p>New features:</p>
<ul>
<li>On the main app, the markdown file is automatically reloaded when it is edited outside.</li>
<li>Preliminary support for Quarto files (<code>.qmd</code>).</li>
</ul>

<p><a href="https://github.com/sbarex/QLMarkdown/blob/master/CHANGELOG.md">See the complete changelog.</a></p>
            ]]>
            </description>
        </item>

        <item>
            <title>1.0.14</title>
            <pubDate>mer, 23 feb 2022 8:50:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0.14/QLMarkdown.zip" sparkle:shortVersionString="1.0.14" sparkle:version="39" sparkle:edSignature="QHWP+IKBRUSqeN4SsKZGWnXiT6o61JxANYenacDK+mv4+i/dBNMKSGBOgsMpiA3i40MYgqtMRi6PKnsoTs8TBQ==" length="15209073" />
            <description><![CDATA[
<h2>1.0.14 (39)</h2>
<p>Bugfix:</p>
<ul>
<li>Allows you to use <code>...</code> to end the <code>yaml</code> header block.</li>
</ul>

<p><b>If you have installed version 1.0.11 or 1.0.12 you may need to <a href="https://github.com/sbarex/QLMarkdown/releases/download/1.0.14/QLMarkdown.zip">re-download the updated app from the web</a>.</b></p>
<ol>
    <li>Unzip the archive</li>
    <li>Replace the app inside the Applications folder</li>
    <li>Start QLMarkdown with right click (or ctrl-click) and choose open from the context menu.</li>
</ol>

<p><a href="https://github.com/sbarex/QLMarkdown/blob/master/CHANGELOG.md">See the complete changelog.</a></p>
            ]]>
            </description>
        </item>

        <item>
            <title>1.0.13</title>
            <pubDate>ven, 11 feb 2022 17:46:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0.13/QLMarkdown.zip" sparkle:shortVersionString="1.0.13" sparkle:version="38" sparkle:edSignature="Ab4qa3kjg0/fxHVVKhQf6fKGmaijy6mAW5a3lf1BQlaKGx4ZpNZsWLLxkkxAW3g9V+/LDaG5VNgFK8hrrsb1BQ==" length="15208656" />
            <description><![CDATA[
<h2>1.0.13 (38)</h2>
<p>Bugfix:</p>
<ul>
<li>Fixed the Sparkle integration bug. </li>
</ul>

<p><b>If you have installed version 1.0.11 or 1.0.12 you may need to <a href="https://github.com/sbarex/QLMarkdown/releases/download/1.0.13/QLMarkdown.zip">re-download the updated app from the web</a>.</b></p>
<ol>
    <li>Unzip the archive</li>
    <li>Replace the app inside the Applications folder</li>
    <li>Start QLMarkdown with right click (or ctrl-click) and choose open from the context menu.</li>
</ol>

<h2>1.0.12 (37)</h2>
<p>Bugfix:</p>
<ul>
<li>Better procedure for install the command line tool.</li>
<li>Fixed the bug that prevented the processing of html raw images when they are not inserted in a html block element. </li>
</ul>
<p><a href="https://github.com/sbarex/QLMarkdown/blob/master/CHANGELOG.md">See the complete changelog.</a></p>
            ]]>
            </description>
        </item>

        <item>
            <title>1.0.12</title>
            <pubDate>ven, 11 feb 2022 15:27:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0.12/QLMarkdown.zip" sparkle:shortVersionString="1.0.12" sparkle:version="37" sparkle:edSignature="shSTbwBhdI2TDFa7sn0kgppuvPjFwC3Z1rUgSOX8l1zSobJ2kcV+5nDNfBdK5p044JWqOazwZRNAOyGGhm3yCA==" length="15208522" />
            <description><![CDATA[
<h2>1.0.12 (37)</h2>
<p>Bugfix:</p>
<ul>
<li>Better procedure for install the command line tool.</li>
<li>Fixed the bug that prevented the processing of html raw images when they are not inserted in a html block element. </li>
</ul>
<p><a href="https://github.com/sbarex/QLMarkdown/blob/master/CHANGELOG.md">See the complete changelog.</a></p>
            ]]>
            </description>
        </item>

        <item>
            <title>1.0.11</title>
            <pubDate>gio, 27 gen 2022 23:54:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0.11/QLMarkdown.zip" sparkle:shortVersionString="1.0.11" sparkle:version="36" sparkle:edSignature="kjzyCI87lb11UsqKnmoOTBomXdFcqBZR3G5g+OFK4op6faJGymN9LZNsAeCgS+OD3DqyAxSXhAtg9ZYCvCDODQ==" length="15206113" />
            <description><![CDATA[
<h2>1.0.11 (36)</h2>
<p>New features:</p>
<ul>
<li>Support for opening markdown files (by dragging the file onto the app icon).</li>
<li>Support for exporting the markdown code.</li>
<li>Sparkle updated to release 2.0.0. </li>
</ul>

<p>Bugfix:</p>
<ul>
<li>Fix for heads with dash.</li>
<li>Implemented missing behavior for the color scheme editor.</li>
<li>Fix for installation of the command line tool.</li>
</ul>
<p><a href="https://github.com/sbarex/QLMarkdown/blob/master/CHANGELOG.md">See the complete changelog.</a></p>
            ]]>
            </description>
        </item>

        <item>
            <title>1.0.10</title>
            <pubDate>lun, 29 dic 2021 16:37:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0.10/QLMarkdown.zip" sparkle:shortVersionString="1.0.10" sparkle:version="35" sparkle:edSignature="Iv1RDXqyC0oSBcD6G8YrSrseiN4VlhX2wl2F56XN/ianDiJ9vD4GfwV/0g/1VSuVqn0mz/zLTJe+gh+j6MUdAw==" length="16424857" />
            <description><![CDATA[
<h2>1.0.10 (35)</h2>
<p>New features:</p>
<ul>
<li>Better performance for heads extension.</li>
<li>Better performance for inline images on raw html fragments.</li>
<li>Option for automatic saving of settings changes.</li>
<li>GUI optimization.</li>
</ul>

<p>Bugfix:</p>
<ul>
<li>Fixed settings save.</li>
</ul>
<p><a href="https://github.com/sbarex/QLMarkdown/blob/master/CHANGELOG.md">See the complete changelog.</a></p>
            ]]>
            </description>
        </item>

        <item>
            <title>1.0</title>
            <pubDate>sab, 26 dic 2020 11:12:25 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b2/QLMardown.zip" sparkle:version="3" sparkle:shortVersionString="1.0" length="14530485" type="application/octet-stream" sparkle:edSignature="Irh4XpVkGNuOqI30m3DFRTPRgDAQuwM62zVH1ONUWpYYHyMCfYkELQH6y8vTkyH3tq9+XIpJWE0fg9Ax3hk+CQ=="/>
            <description><![CDATA[
                <p>First version.</p>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>dom, 27 dic 2020 12:14:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b4/QLMardown.zip" sparkle:version="4" sparkle:shortVersionString="1.0" type="application/octet-stream" sparkle:edSignature="OGauStX9L1R5Fabd8A4UkCVR5avBwYPjFKdswCI39MnhGs/g4Pu8nGqxmF33SLZRjef5OZRezQ5noLkal/NeDA==" length="15841541"/>
            <description><![CDATA[
                <p>Auto update with Sparkle framework and bugfix.</p>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>dom, 27 dic 2020 13:51:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b5/QLMardown.zip" sparkle:version="5" sparkle:shortVersionString="1.0" type="application/octet-stream" sparkle:edSignature="CrhKLFzwzVM9+KHYTctY9DvBEpgww4bui3mkrUZ+ViJDuprM2mro1jZzYC09koKugeY/B362IPTvsycmM87WBA==" length="17622201"/>
            <description><![CDATA[
                <p>Fix missed Sparkle framework.</p>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>dom, 27 dic 2020 17:49:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b6/QLMardown.zip" sparkle:version="6" sparkle:shortVersionString="1.0" type="application/octet-stream" sparkle:edSignature="kmSuZ3yP1fOgP5dgwk0HCK07U+VsIvGSlQkW51zuyzy6B8H/X1Z10pzyaxz/ndLu2frJklVmew26CfSK5PE4AQ==" length="17622232"/>
            <description><![CDATA[
                <p>UI improvements and bugfix.</p>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>mar, 29 dic 2020 18:36:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b7/QLMarkdown.zip" sparkle:version="7" sparkle:shortVersionString="1.0" type="application/octet-stream" sparkle:edSignature="e+jzbC/6vyrH/NGtcFigt6biD+vv4XVO4ALAb+Ljc2PbJz3Z+f7z6MjB+Cst+8KPv+1iJsRfiM3T2x734UdmBg==" length="17682841"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
    <li><code>Heads extension</code> to auto create anchor for the heads.</li>
    <li>Redesigned UI.</li>
    <li>Auto refresh menu to automatically update the preview when an option is changed (the auto refresh do not apply when you change the example text). </li>
    <li>The quicklook extension detects the settings changed on the host application. Remember that macOS can store the quicklook preview in a cache, so to see the new settings applied try to open the preview of a different file.</li>
    <li>On the host application you can open a .md file to view in the preview (you can also drag & drop the over the text editor).</li>
    <li>Import css inside the support folder.</li>
</ul>
<p>Bugfix:</p>
<ul>
    <li>Typo in application name.</li>
    <li>Null pointer bug on inlineimage extension.</li>
    <li>Fix on the image mime detection.</li>
</ul>

<p><b>Warning</b>: I fix a typo in the application name. The autoupdate can fail. In this case please redownload the app. </p>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>mar, 29 dic 2020 20:00:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b8/QLMarkdown.zip" sparkle:version="8" sparkle:edSignature="pdGKJmGSSuz9I/2QSUqOzWfDex3ucmCXSTLeWreQCBflSb6gOY58MHY7EQ8sOxxspiBAKUEWrI+th6kXms9PAA==" length="17683533"/>
            <description><![CDATA[
<p>Fixed standard cmark task list extension not inserting class style. </p>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>mar, 29 dic 2020 20:48:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b9/QLMarkdown.zip" sparkle:version="9" sparkle:edSignature="ipYWJqck7KdadlC5QWR9/WWwCZ3sE1vBf3B72qcE4nRxYj9AB9AvCS37+0bAaRHwGd8qkeivRz0o+ZgwwIEeBQ==" length="17682527"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
<li>Updated the default css style (thanks to <a href="https://github.com/hazarek">hazarek</a>).</li>
<li>For source highlight, option to choose the document style or a specific language style.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>mar, 30 dic 2020 17:10:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b10/QLMarkdown.zip" sparkle:version="10" sparkle:edSignature="JWzjW5WsJ1l2cuovUK3KFalBHOfBXIAlaUs+bH1uqibzNGzzWJyQGEBIq5hbWU/MuUURghyhfQ1YHAv2dpXTCA==" length="17706862"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
<li>Implemented reset to factory settings.</li>
</ul>
<p>Bugfix:</p>
<ul>
<li>Incomplete saving settings.</li>
<li>UI fix.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>mar, 30 dic 2020 17:52:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b11/QLMarkdown.zip" sparkle:version="11" sparkle:edSignature="/w1kJjt79fv+M1KZ7iQN1x7CYgsMQ2gTkPX8zCGgq4aO/NIj3sRA4GTUJ3EER1HXn/QqyJYeQWAR6ZBeG9ZdCQ==" length="17751190"/>
            <description><![CDATA[
<p>Bugfix:</p>
<ul>
<li>Fixed open external link to the default browser on Big Sur (via an external XPC service).</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>ven, 1 gen 2021 09:42:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b12/QLMarkdown.zip" sparkle:version="12" sparkle:edSignature="6JYGcK1HFYRxDLlMTe+JqlDpNxZJBMI7eDHPehKnAVVJ/HuGs46E1cS005e0XE2pzvS5lAcrQPBHhuelOypUBA==" length="12470511"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
<li>New icon (thanks to <a href="https://github.com/hazarek">hazarek</a>).</li>
<li>Wrapper highlight library build inside the Xcode project.</li>
<li>Wrapper highlight embed goutils with enry guess engine.</li>
<li>Better about dialog.</li>
</ul>
<p>Bugfix:</p>
<ul>
<li>Shared library and support files no more embedded twice reducing the total file size.</li>
<li>Fix on exporting default style.</li>
<li>Css theme fix.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>sab, 2 gen 2021 18:26:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b13/QLMarkdown.zip" sparkle:version="13" sparkle:edSignature="ROJzhUf0rCAXRXgCTEYU7hDY7l03Qv2PgNfCN+rT6LoyxbcG/ZvUrFJPoohiAxS0PrqemLcq0L7REA86w3hDDQ==" length="12482212"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
<li>QL preview handle TextBundle container.</li>
<li>Inline image extension handle also image inserted with <image> tag on the markdown file.</li>
<li>Better emoji handler.</li>
</ul>
<p>Bugfix:</p>
<ul>
<li>Fix error on image mime detection.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>dom, 3 gen 2021 17:08:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b14/QLMarkdown.zip" sparkle:version="14" sparkle:edSignature="sAl5yacqKZj8IBtKLIZtsv6N1T7o+1CbqWeXNqAJFSKK/fQVSLtKxXDrXNmPhu7BUnrKY7jLMV361UiiiflrBA==" length="11835950"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
<li>Better emoji handler.</li>
<li>UI improvement.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>dom, 3 gen 2021 17:08:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b15/QLMarkdown.zip" sparkle:version="15" sparkle:edSignature="bfu8114v/kZ7cF7siPDZpuEQrVMMNq+dcs40ZLzlhfL63DWOV4zUy1aN+gH3+jd2VL6Hv9BbA24CkIc0qAVFBA==" length="12106518"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
<li>Option to export the generated preview to an HTML file in the main application.</li>
</ul>
<p>Bugfix:</p>
<ul>
<li>Fix emoji parser.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>sab, 16 gen 2021 22:34:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b16/QLMarkdown.zip" sparkle:version="16" sparkle:edSignature="7cNID0icKFdLSyFsFVZgyLklo/vHcjOJiJTXkR2aJf9emPdsvg5xs8bblNsO27OIWDVJThKOEkcZksWeQZloDw==" length="12230133"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
<li>Option to export the generated preview to an HTML file in the main application.</li>
</ul>
<p>Bugfix:</p>
<ul>
<li>Fix on heads extension.</li>
<li>Fix on emoji extension.</li>
<li>Fix for exporting a source color scheme as a CSS style.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>mer, 20 gen 2021 19:15:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b17/QLMarkdown.zip" sparkle:version="17" sparkle:edSignature="LXxjhpf4/yr+jOvZIxpA2+6W3f3zeXgqftLylt5buT8Ysy8Y08mqZkWyX7dUzLsfYLQGkm3CkNkmbrXxx7LYAw==" length="12274642"/>
            <description><![CDATA[
<p>Bugfix:</p>
<ul>
<li>Better mime recognition for inline images.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>gio, 21 gen 2021 08:23:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b18/QLMarkdown.zip" sparkle:version="18" sparkle:edSignature="VMrIKkkvV+OpthEWDSjn6O5YTeAb52pQIr+xc27hiCR55s6vbAxwJjk5asYklimUYfASIMZ2ep34mfh/s81eAw==" length="12277698"/>
            <description><![CDATA[
<p>Bugfix:</p>
<ul>
<li>Fixed base64 image encoding.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>lun, 1 feb 2021 22:41:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b19/QLMarkdown.zip" sparkle:version="19" sparkle:edSignature="9g8fZuLOtQosHCAj4IlQGHNGhdjMW+adCQ8MZjvO+5sspGWL0WwWGrRdBmYCFTVRLo40vH505TWuiEWixxfBAQ==" length="12277846"/>
            <description><![CDATA[
<p>Bugfix:</p>
<ul>
<li>Responsive image height fix.</li>
<li>Correct parsing of image filename with spaces inside a <code>&lt;img></code> tag. Please note that spaces are not supported within the filenames of images defined with markdown syntax. Spaces are unsafe to use inside an URL, must be replaced with <code>%20</code>.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>gio, 4 feb 2021 20:13:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b20/QLMarkdown.zip" sparkle:version="20" sparkle:edSignature="8DK0kFN4n7Wm8JZYyYbTaCWM/Ofy3kHoQWDF8TSZeEbLIQhJYvzp/6lGRt+sRyXwVj4b/Mx5H919X4KbDXB3AQ==" length="12484347"/>
            <description><![CDATA[
<p>Bugfix:</p>
<ul>
<li>Fix for anchors of head with emoji characters.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>gio, 4 feb 2021 23:04:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b21/QLMarkdown.zip" sparkle:version="21" sparkle:edSignature="KMY/WoqWP1LNrJYguM1H29JQ35PV7Pw6bREmAgdWSUdtuehgvxc6v5ZfrkxG0saDoWEEGXrfjTRzqf3kDnWzBw==" length="12487417"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
<li>Settings to handle autoupdate.</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>mar, 9 feb 2021 15:36:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b22/QLMarkdown.zip" sparkle:version="22" sparkle:edSignature="Khe5GOg8GWcR/gBsRuZ4lbPd1yc6yC8asvmTBY5YUBFRjhyqMA6V2/VXnYS9XMFXoGltVqeSMPRbyogLumfhCw==" length="12487323"/>
            <description><![CDATA[
<p>Bugfix:</p>
<ul>
<li>Fixed a glitch when showing the preview (the webview is initially shown smaller than the QL window).</li>
</ul>
            ]]>
            </description>
        </item>
        <item>
            <title>1.0</title>
            <pubDate>dom, 21 feb 2021 17:10:00 +0100</pubDate>
            <sparkle:minimumSystemVersion>10.15</sparkle:minimumSystemVersion>
            <enclosure url="https://github.com/sbarex/QLMarkdown/releases/download/1.0b23/QLMarkdown.zip" sparkle:version="23" sparkle:edSignature="FEhbby1FdHqf/D4n8F5TUsXbL7BkmDF0ehA/imLOP8XwXiov/UIuV6+5LqhhL3GsObpuxhlN7w/bSjLJK/MbAg==" length="12487519"/>
            <description><![CDATA[
<p>New features:</p>
<ul>
<li>Support for UTI <code>com.unknown.md</code>.</li>
</ul>
            ]]>
            </description>
        </item>

    </channel>
</rss>

"""

class SparkeRandomVersionsTests: XCTestCase {
    func testGetCorrectVersion() throws {
        let app = AppCast(data: Data(sourceXMLwrongversions.utf8))
        assert(app.version == "1.0.15")
    }
}
