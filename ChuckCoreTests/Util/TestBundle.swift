//
//  TestBundle.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

private final class TestBundleInitializer { }

enum TestResource: String {
    case categories
    case randomWithCategory
    case random
    case search
    case searchEmpty

    static var all: [TestResource] = [.categories, .randomWithCategory, .random, .search, .searchEmpty]
}

enum TestResourceError: Error {
    case notFound(String)

    var localizedDescription: String {
        switch self {
        case .notFound(let name):
            return "A required resource for ChuckCoreTests is not present in the bundle: \(name)"
        }
    }
}

extension Bundle {

    func fetch(resource: TestResource) throws -> Data {
        guard let url = Bundle.chuckCore.url(forResource: resource.rawValue, withExtension: "json") else {
            throw TestResourceError.notFound(resource.rawValue)
        }

        return try Data(contentsOf: url)
    }

}
