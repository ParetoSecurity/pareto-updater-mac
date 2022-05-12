//
//  Pareto_UpdaterUITestsLaunchTests.swift
//  Pareto UpdaterUITests
//
//  Created by Janez Troha on 14/04/2022.
//

import XCTest

class ParetoUpdaterUITestsLaunchPreferences: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        app.waitForExistence(timeout: 10)
        let menuBarsQuery = app.menuBars
        menuBarsQuery.statusItems.firstMatch.rightClick()
        menuBarsQuery/*@START_MENU_TOKEN@*/ .menuItems["preferences"]/*[[".statusItems[\"download multiple\"]",".menus",".menuItems[\"Preferences\"]",".menuItems[\"preferences\"]"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/ .click()
        app.windows["General"].toolbars.buttons["Apps"].click()
        app.windows["Apps"].toolbars.buttons["About"].click()
    }
}
