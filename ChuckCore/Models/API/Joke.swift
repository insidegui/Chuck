//
//  Joke.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct Joke: Codable {
    public let id: String
    public let iconUrl: URL
    public let category: String?
    public let url: URL
    public let value: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        iconUrl = try container.decode(URL.self, forKey: .iconUrl)
        url = try container.decode(URL.self, forKey: .url)
        value = try container.decode(String.self, forKey: .value)

        if let categories = try? container.decode([String].self, forKey: .category) {
            // The category is represented as an array with one item in some responses
            category = categories.first
        } else {
            category = try container.decode(String?.self, forKey: .category)
        }
    }
}
