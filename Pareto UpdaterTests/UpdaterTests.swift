//
//  UpdaterTests.swift
//  Pareto UpdaterTests
//
//  Created by Janez Troha on 05/07/2022.
//

@testable import Pareto_Updater
import XCTest

final class UpdaterTests: XCTestCase {
    func testIconSpecial() throws {
        let app = AppGoogleChrome.sharedInstance
        assert(app.icon != nil)
    }
}
