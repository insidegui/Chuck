//
//  SearchResponse+Sample.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import XCTest
@testable import ChuckCore

extension SearchResponse {

    static func sample() throws -> SearchResponse {
        let data = try Bundle.testBundle.fetch(resource: .search)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(SearchResponse.self, from: data)

        return response
    }

}
