//
//  RecentSearch.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct RecentSearch: Equatable {

    public let createdAt: Date
    public let term: String

    public init(term: String, createdAt: Date = Date()) {
        self.createdAt = createdAt
        self.term = term
    }

}
