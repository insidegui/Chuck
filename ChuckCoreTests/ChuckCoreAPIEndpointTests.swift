//
//  ChuckCoreAPIEndpointTests.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import XCTest
@testable import ChuckCore

class ChuckCoreAPIEndpointTests: XCTestCase {

    func testRandomEndpointRequestGeneration() {
        let request = ChuckAPIEndpoint<Joke>.random().request
        XCTAssertEqual(request?.url?.absoluteString, "https://api.chucknorris.io/jokes/random?")
    }

    func testRandomWithCategoryRequestGeneration() {
        let request = ChuckAPIEndpoint<Joke>.random(with: "dev").request
        XCTAssertEqual(request?.url?.absoluteString, "https://api.chucknorris.io/jokes/random?category=dev")
    }

    func testCategoriesRequestGeneration() {
        let request = ChuckAPIEndpoint<[ChuckCore.Category]>.categories().request
        XCTAssertEqual(request?.url?.absoluteString, "https://api.chucknorris.io/jokes/categories?")
    }

    func testSimpleSearchRequestGeneration() {
        let request = ChuckAPIEndpoint<SearchResponse>.search(with: "iPhone").request
        XCTAssertEqual(request?.url?.absoluteString, "https://api.chucknorris.io/jokes/search?query=iPhone")
    }

    func testSearchWithSpecialCharactersRequestGeneration() {
        let request = ChuckAPIEndpoint<SearchResponse>.search(with: "Caffè Macs").request
        XCTAssertEqual(request?.url?.absoluteString, "https://api.chucknorris.io/jokes/search?query=Caff%25C3%25A8%2520Macs")
    }

}
