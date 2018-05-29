//
//  ChuckAPIEndpoint.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import os.log

struct ChuckAPIEndpoint<R: Codable> {

    private let path: String
    private let query: [URLQueryItem]
    private let environment: ChuckAPIEnvironment

    private init(path: String, query: [URLQueryItem] = [], environment: ChuckAPIEnvironment = .production) {
        self.path = path
        self.query = query
        self.environment = environment
    }

    /// An endpoint appropriate for getting a random joke
    static func random(environment: ChuckAPIEnvironment = .production) -> ChuckAPIEndpoint<Joke> {
        return ChuckAPIEndpoint<Joke>(path: "/jokes/random", environment: environment)
    }

    /// An endpoint appropriate for getting a list of available categories
    static func categories(environment: ChuckAPIEnvironment = .production) -> ChuckAPIEndpoint<[Category]> {
        return ChuckAPIEndpoint<[Category]>(path: "/jokes/categories", environment: environment)
    }

    /// Random
    ///
    /// - Parameter category: the category to get the jokes for
    /// - Returns: An endpoint appropriate for getting jokes with the specified category
    static func random(with category: String, environment: ChuckAPIEnvironment = .production) -> ChuckAPIEndpoint<Joke> {
        let query = [URLQueryItem(name: "category", value: category)]

        return ChuckAPIEndpoint<Joke>(path: "/jokes/random", query: query, environment: environment)
    }

    /// Search
    ///
    /// - Parameter term: the term to search for
    /// - Returns: An endpoint appropriate for searching with the specified term
    static func search(with term: String, environment: ChuckAPIEnvironment = .production) -> ChuckAPIEndpoint<SearchResponse> {
        // If the sanitization fails, we use the original term. It think this is a good approach since
        // it will more than likely result in an HTTP request error that ends up bubbling up to the UI
        let query = [URLQueryItem(name: "query", value: term)]

        return ChuckAPIEndpoint<SearchResponse>(path: "/jokes/search", query: query, environment: environment)
    }

    var request: URLRequest? {
        return environment.resolve(path: path, query: query)
    }

}
