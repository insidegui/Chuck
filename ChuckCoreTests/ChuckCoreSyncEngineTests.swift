//
//  ChuckCoreSyncEngineTests.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import XCTest

import RxSwift
import RxCocoa
import RxCoreData
import RxBlocking

@testable import ChuckCore

class ChuckCoreSyncEngineTests: XCTestCase {

    var engine: SyncEngine!

    override func setUp() {
        let client = ChuckAPIClient(environment: .test)
        engine = SyncEngine(client: client, persistentContainer: .test)
    }

    func testFetchingAllCategories() throws {
        try engine.syncCategories().toBlocking().single()

        let categories = try engine.fetchCategories().toBlocking().first()

        XCTAssertNotNil(categories)
        XCTAssertEqual(categories?.count, 16)
    }

    func testFetchingRandomCategorySelection() throws {
        try engine.syncCategories().toBlocking().single()

        let categories = try engine.fetchRandomCategories(with: 8).toBlocking().first()
        let categories2 = try engine.fetchRandomCategories(with: 8).toBlocking().first()

        XCTAssertEqual(categories?.count, 8)
        XCTAssertEqual(categories2?.count, 8)

        XCTAssertNotNil(categories)
        XCTAssertNotNil(categories2)

        // Two selections in a row must never be equal
        XCTAssertNotEqual(categories, categories2)
    }

    func testFetchingRandomCategorySelectionBeyondBounds() throws {
        try engine.syncCategories().toBlocking().single()

        // There are only 16 categories
        let categories = try engine.fetchRandomCategories(with: 17).toBlocking().first()

        XCTAssertNotNil(categories)
        XCTAssertEqual(categories?.count, 16)
    }

    func testFetchSearchResults() throws {
        try engine.syncSearchResults(with: "Steve Jobs").toBlocking().single()

        let viewModels = try engine.fetchSearchResults(with: "Steve Jobs").toBlocking().first()

        XCTAssertNotNil(viewModels)
        XCTAssertEqual(viewModels?.count, 1)
        XCTAssertEqual(viewModels?.first?.id, "ulsiraupTqykbsK70ifGxw")
    }

    func testFetchRandomJokes() throws {
        try engine.syncSearchResults(with: "iPhone").toBlocking().single()

        let viewModels = try engine.fetchRandomJokes(with: 5).toBlocking().first()
        let viewModels2 = try engine.fetchRandomJokes(with: 5).toBlocking().first()

        XCTAssertNotNil(viewModels)
        XCTAssertEqual(viewModels?.count, 5)
        XCTAssertEqual(viewModels2?.count, 5)

        XCTAssertNotEqual(viewModels, viewModels2)
    }

    func testFetchSingleJoke() throws {
        let joke = try engine.randomJoke().toBlocking().first()

        XCTAssertNotNil(joke)
        XCTAssertEqual(joke?.id, "2cZa3wC8Ts-UI4TiFaFQVw")
    }

}
