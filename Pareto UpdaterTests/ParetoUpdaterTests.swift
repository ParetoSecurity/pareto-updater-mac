//
//  Pareto_UpdaterTests.swift
//  Pareto UpdaterTests
//
//  Created by Janez Troha on 14/04/2022.
//

@testable import Pareto_Updater
import XCTest

class ParetoUpdaterTests: XCTestCase {
    func testCurrentVersion() throws {
        let bundles = AppBundles()
        for app in bundles.apps {
            app.currentVersion
        }
    }

    func testLatestVersion() throws {
        let bundles = AppBundles()
        for app in bundles.apps {
            app.latestVersion
        }
    }

    func testInstall() throws {
        let bundles = AppBundles()
        for app in bundles.apps {
            app.updateApp { status in
                assert(status == .Updated)
            }
        }
    }
}
