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
}
