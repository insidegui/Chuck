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

        app.launchArguments.append("--uitests")

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

    func testSearchWithResultsShowsResultsOnList() {
        app.buttons[UITestingLabel.searchButton.rawValue].tap()

        let searchBar = app.otherElements[UITestingLabel.searchBar.rawValue]
        searchBar.tap()
        searchBar.typeText("iPhone\n")

        let element = app.otherElements[UITestingLabel.emptyView.rawValue]
        let predicate = NSPredicate(format: "isHittable == 0")

        expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testSearchWithNoResultsShowsEmptyView() {
        app.buttons[UITestingLabel.searchButton.rawValue].tap()

        let searchBar = app.otherElements[UITestingLabel.searchBar.rawValue]
        searchBar.tap()
        searchBar.typeText("empty\n")

        XCTAssertTrue(app.otherElements[UITestingLabel.emptyView.rawValue].isHittable)
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
