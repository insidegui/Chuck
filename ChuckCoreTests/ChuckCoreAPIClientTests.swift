//
//  ChuckCoreAPIClientTests.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import XCTest

import RxSwift
import RxBlocking

@testable import ChuckCore

class ChuckCoreAPIClientTests: XCTestCase {

    func testRandomEndpoint() throws {
        let client = ChuckAPIClient(environment: .test)
        let joke = try client.random.toBlocking().first()

        XCTAssertNotNil(joke)
        XCTAssertEqual(joke?.categories.count, 0)
        XCTAssertEqual(joke?.iconUrl.absoluteString, "https://assets.chucknorris.host/img/avatar/chuck-norris.png")
        XCTAssertEqual(joke?.id, "2cZa3wC8Ts-UI4TiFaFQVw")
        XCTAssertEqual(joke?.url.absoluteString, "https://api.chucknorris.io/jokes/2cZa3wC8Ts-UI4TiFaFQVw")
        XCTAssertEqual(joke?.value, "Chuck Norris is Mysterion.")
    }

    func testRandomWithCategoryEndpoint() throws {
        let client = ChuckAPIClient(environment: .test)
        let joke = try client.random(with: "test").toBlocking().first()

        XCTAssertNotNil(joke)
        XCTAssertEqual(joke?.categories.count, 1)
        XCTAssertEqual(joke?.categories.first?.name, "political")
        XCTAssertEqual(joke?.iconUrl.absoluteString, "https://assets.chucknorris.host/img/avatar/chuck-norris.png")
        XCTAssertEqual(joke?.id, "uanj8roxsrwq6pgb0kufia")
        XCTAssertEqual(joke?.url.absoluteString, "https://api.chucknorris.io/jokes/uanj8roxsrwq6pgb0kufia")
        XCTAssertEqual(joke?.value, "Guantuanamo Bay, Cuba, is the military code-word for \"Chuck Norris\' basement\".")
    }

    func testCategoriesEndpoint() throws {
        let client = ChuckAPIClient(environment: .test)
        let categories = try client.categories.toBlocking().first()

        XCTAssertNotNil(categories)
        XCTAssertEqual(categories?.first?.name, "explicit")
        XCTAssertEqual(categories?.last?.name, "fashion")
    }

    func testSearchEndpoint() throws {
        let client = ChuckAPIClient(environment: .test)
        let response = try client.search(with: "test").toBlocking().first()

        XCTAssertNotNil(response)
        XCTAssertEqual(response?.total, 8)
        XCTAssertEqual(response?.result.count, 8)

        let joke = response?.result.first

        XCTAssertEqual(joke?.categories.count, 0)
        XCTAssertEqual(joke?.iconUrl.absoluteString, "https://assets.chucknorris.host/img/avatar/chuck-norris.png")
        XCTAssertEqual(joke?.id, "RDCtS4GjQpmwByA3ytBs2A")
        XCTAssertEqual(joke?.url.absoluteString, "https://api.chucknorris.io/jokes/RDCtS4GjQpmwByA3ytBs2A")
        XCTAssertEqual(joke?.value, "I just downloaded the new \"Roundhouse Kick\" app for my iPhone and now my screen is cracked and the phone does not work. Damn you, Chuck Norris.")
    }

    func testSearchEndpointWithNoResults() throws {
        let client = ChuckAPIClient(environment: .test)
        let response = try client.search(with: "empty").toBlocking().first()

        XCTAssertNotNil(response)
        XCTAssert(response?.total == 0)
        XCTAssertNil(response?.result.first)
    }

}
