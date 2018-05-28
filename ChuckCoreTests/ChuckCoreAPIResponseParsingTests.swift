//
//  ChuckCoreAPIResponseParsingTests.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import XCTest
@testable import ChuckCore

class ChuckCoreAPIResponseParsingTests: XCTestCase {

    /// Make sure all required resources are available for the tests, this test will fail if any
    /// of the required resources is not available in the test bundle
    func testBundleIntegrity() throws {
        try TestResource.all.forEach { _ = try Bundle.chuckCore.fetch(resource: $0) }
    }

    func testSearchResponseWithResultsParsing() throws {
        let data = try Bundle.chuckCore.fetch(resource: .search)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(SearchResponse.self, from: data)

        let firstJoke = response.result.first
        XCTAssertNotNil(firstJoke)

        XCTAssert(response.total == 8)
        XCTAssert(response.result.count == 8)
        XCTAssert(firstJoke?.id == "RDCtS4GjQpmwByA3ytBs2A")
        XCTAssert(firstJoke?.value == "I just downloaded the new \"Roundhouse Kick\" app for my iPhone and now my screen is cracked and the phone does not work. Damn you, Chuck Norris.")
        XCTAssert(firstJoke?.url.absoluteString == "https://api.chucknorris.io/jokes/RDCtS4GjQpmwByA3ytBs2A")
        XCTAssert(firstJoke?.iconUrl.absoluteString == "https://assets.chucknorris.host/img/avatar/chuck-norris.png")
    }

    func testEmptySearchResultsParsing() throws {
        let data = try Bundle.chuckCore.fetch(resource: .searchEmpty)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(SearchResponse.self, from: data)

        XCTAssert(response.total == 0)
        XCTAssertNil(response.result.first)
    }

    func testCategoriesParsing() throws {
        let data = try Bundle.chuckCore.fetch(resource: .categories)

        let categories = try JSONDecoder().decode([String].self, from: data)
        XCTAssert(categories.count == 16)
        XCTAssert(categories.first == "explicit")
        XCTAssert(categories.last == "fashion")
    }

    func testRandomResponseParsing() throws {
        let data = try Bundle.chuckCore.fetch(resource: .random)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(Joke.self, from: data)

        XCTAssert(response.categories.count == 0)
        XCTAssert(response.id == "2cZa3wC8Ts-UI4TiFaFQVw")
        XCTAssert(response.value == "Chuck Norris is Mysterion.")
        XCTAssert(response.url.absoluteString == "https://api.chucknorris.io/jokes/2cZa3wC8Ts-UI4TiFaFQVw")
        XCTAssert(response.iconUrl.absoluteString == "https://assets.chucknorris.host/img/avatar/chuck-norris.png")
    }

    func testRandomResponseWithCategoryParsing() throws {
        let response = try Joke.sample()

        validateSampleJokeFields(with: response)
    }
    
}
