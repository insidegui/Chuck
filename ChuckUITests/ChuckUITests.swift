//
//  ChuckUITests.swift
//  ChuckUITests
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import XCTest
@testable import ChuckCore

class ChuckUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        app = XCUIApplication()

        app.launchArguments.append("-isRunningUITests YES")

        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEmptyViewIsDisplayedOnFirstLaunch() {
        XCTAssertTrue(app.isShowingEmptyScreen)
    }

    func testTappingSearchButtonShowsSearchUI() {
        app.buttons[UITestingLabel.searchButton.rawValue].tap()
        XCTAssertTrue(app.isShowingSearch)
    }
    
}

extension XCUIApplication {

    var isShowingEmptyScreen: Bool {
        return otherElements[UITestingLabel.emptyView.rawValue].exists
    }

    var isShowingSearch: Bool {
        return otherElements[UITestingLabel.searchView.rawValue].exists
    }

}
