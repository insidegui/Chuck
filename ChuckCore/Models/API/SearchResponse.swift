//
//  SearchResponse.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct SearchResponse: Codable {
    public let total: Int
    public let result: [Joke]
}
