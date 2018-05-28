//
//  RecentSearchViewModel.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import RxDataSources

public struct RecentSearchViewModel: Equatable, IdentifiableType {

    public typealias Identity = String

    public var identity: String {
        return recentSearch.term
    }

    public let recentSearch: RecentSearch

    public init(with recentSearch: RecentSearch) {
        self.recentSearch = recentSearch
    }

    public var term: String {
        return recentSearch.term.uppercased()
    }

}
