//
//  Joke+Sample.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import XCTest
@testable import ChuckCore

extension Joke {

    static func sample() throws -> Joke {
        let data = try Bundle.chuckCore.fetch(resource: .randomWithCategory)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(Joke.self, from: data)

        return response
    }

}

extension XCTestCase {

    func validateSampleJokeFields(with joke: Joke) {
        XCTAssert(joke.categories.count == 1)
        XCTAssert(joke.categories.first?.name == "political")
        XCTAssert(joke.id == "uanj8roxsrwq6pgb0kufia")
        XCTAssert(joke.value == "Guantuanamo Bay, Cuba, is the military code-word for \"Chuck Norris\' basement\".")
        XCTAssert(joke.url.absoluteString == "https://api.chucknorris.io/jokes/uanj8roxsrwq6pgb0kufia")
        XCTAssert(joke.iconUrl.absoluteString == "https://assets.chucknorris.host/img/avatar/chuck-norris.png")
    }

}
