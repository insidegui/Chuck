//
//  Category.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct Category: Codable, Equatable {
    public let name: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        name = try container.decode(String.self)
    }
}
