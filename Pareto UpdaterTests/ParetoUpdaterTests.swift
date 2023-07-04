//
//  Pareto_UpdaterTests.swift
//  Pareto UpdaterTests
//
//  Created by Janez Troha on 14/04/2022.
//

@testable import Pareto_Updater
import XCTest
import XMLCoder

class ParetoUpdaterTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        try! Constants.versionStorage.removeAll()
        try! Constants.versionStorage.removeExpiredObjects()
    }

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

    func testPrusaSlicer() throws {
        let app = AppMTeams.sharedInstance
        print(app.latestVersion)
        print(app.currentVersion)
        print(app.currentVersion)
    }
}
