//
//  CategoryViewModel.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import RxDataSources

public struct CategoryViewModel: Equatable, IdentifiableType {

    public typealias Identity = String

    public var identity: String {
        return category.name
    }

    public let category: Category

    public init(category: Category) {
        self.category = category
    }

    public var name: String {
        return category.name.uppercased()
    }

}
