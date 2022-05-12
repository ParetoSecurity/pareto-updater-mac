//
//  Pareto_UpdaterUITestsLaunchTests.swift
//  Pareto UpdaterUITests
//
//  Created by Janez Troha on 14/04/2022.
//

import XCTest

class ParetoUpdaterUITestsLaunchPopup: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        app.waitForExistence(timeout: 10)
        let menuBarsQuery = app.menuBars
        menuBarsQuery.statusItems.firstMatch.click()
    }
}
