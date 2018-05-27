//
//  JokeViewModel.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxDataSources

public struct JokeViewModel: Equatable, IdentifiableType {

    public typealias Identity = String

    public var identity: String {
        return id
    }

    public struct Metrics: Equatable {
        public let fontSize: CGFloat
        public let fontWeight: UIFont.Weight

        public static let large = Metrics(fontSize: 28, fontWeight: .semibold)
        public static let regular = Metrics(fontSize: 16, fontWeight: .regular)
    }

    public let joke: Joke
    public let categoryViewModel: CategoryViewModel?

    public init(joke: Joke) {
        self.joke = joke

        if let firstCategory = joke.categories.first {
            categoryViewModel = CategoryViewModel(category: firstCategory)
        } else {
            categoryViewModel = nil
        }
    }

    public var id: String {
        return joke.id
    }

    public var body: String {
        return joke.value
    }

    public var categoryName: String {
        return categoryViewModel?.name ?? "UNCATEGORIZED"
    }

    public var preferredMetrics: Metrics {
        switch body.count {
        case 0...80:
            return .large
        default:
            return .regular
        }
    }

}
