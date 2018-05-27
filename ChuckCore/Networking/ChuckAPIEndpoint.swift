//
//  ChuckAPIEndpoint.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import os.log

struct ChuckAPIEndpoint {

    private let baseComponents = URLComponents(string: "https://api.chucknorris.io")!

    private let path: String
    private let query: [URLQueryItem]

    private init(path: String, query: [URLQueryItem] = []) {
        self.path = path
        self.query = query
    }

    /// An endpoint appropriate for getting a random joke
    static let random = ChuckAPIEndpoint(path: "/jokes/random")

    /// An endpoint appropriate for getting a list of available categories
    static let categories = ChuckAPIEndpoint(path: "/jokes/categories")

    /// Random
    ///
    /// - Parameter category: the category to get the jokes for
    /// - Returns: An endpoint appropriate for getting jokes with the specified category
    static func random(with category: String) -> ChuckAPIEndpoint {
        let query = [URLQueryItem(name: "category", value: category)]

        return ChuckAPIEndpoint(path: "/jokes/random", query: query)
    }

    /// Search
    ///
    /// - Parameter term: the term to search for
    /// - Returns: An endpoint appropriate for searching with the specified term
    static func search(with term: String) -> ChuckAPIEndpoint {
        let sanitizedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        if sanitizedTerm == nil { os_log("Failed to sanitize search term %@", log: .default, type: .fault, term) }

        // If the sanitization fails, we use the original term. It think this is a good approach since
        // it will more than likely result in an HTTP request error that ends up bubbling up to the UI
        let query = [URLQueryItem(name: "query", value: sanitizedTerm ?? term)]

        return ChuckAPIEndpoint(path: "/jokes/search", query: query)
    }

    var request: URLRequest? {
        var components = baseComponents

        components.path = path
        components.queryItems = query

        guard let url = components.url else {
            os_log(
                "Failed to generate URL for endpoint %@",
                log: .default,
                type: .error,
                String(describing: self)
            )
            return nil
        }

        return URLRequest(url: url)
    }

}
