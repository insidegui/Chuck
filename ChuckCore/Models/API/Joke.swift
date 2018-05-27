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
    public let categories: [String]
    public let url: URL
    public let value: String

    public enum CodingKeys: String, CodingKey {
        case id, iconUrl, url, value
        case categories = "category"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        iconUrl = try container.decode(URL.self, forKey: .iconUrl)
        url = try container.decode(URL.self, forKey: .url)
        value = try container.decode(String.self, forKey: .value)

        if let decodedCategories = try? container.decode([String].self, forKey: .categories) {
            categories = decodedCategories
        } else {
            // Set categories to an empty array when the category field can't be decoded
            categories = []
        }
    }
}
