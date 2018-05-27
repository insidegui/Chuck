//
//  Joke.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct Joke: Codable, Equatable {
    public let id: String
    public let iconUrl: URL
    public let categories: [Category]
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

        let decodedCategories = try? container.decode([Category].self, forKey: .categories)
        categories = decodedCategories ?? []
    }
}
