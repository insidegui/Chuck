//
//  SyncEngine.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import CoreData
import RxCoreData
import RxSwift
import RxCocoa
import RxDataSources

public final class SyncEngine {

    public let client: ChuckAPIClient
    public let persistentContainer: NSPersistentContainer

    public init(client: ChuckAPIClient, persistentContainer: NSPersistentContainer) {
        self.client = client
        self.persistentContainer = persistentContainer
    }

    private var moc: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Syncs categories from the API and stores the results in the database
    ///
    /// - Returns: An Observable that can be used to check for completion and errors
    public func syncCategories() -> Observable<Void> {
        return client.categories.do(onNext: { [unowned self] categories in
            try categories.forEach(self.moc.rx.update)
        }).map { _ in Void() }
    }

    /// Performs a fetch on the database to get all categories
    ///
    /// - Returns: An Observable for an array of CategoryViewModel for the UI
    public func fetchCategories() -> Observable<[CategoryViewModel]> {
        return moc.rx.entities(Category.self).map { categories in
            return categories.map(CategoryViewModel.init)
        }
    }

    /// Performs a fetch on the database and returns a random selection of categories
    ///
    /// - Parameter count: The number of categories to get
    /// - Returns: A random selection of categories with the amount specified (limited by the number of categories available)
    public func fetchRandomCategories(with count: Int = 8) -> Observable<[CategoryViewModel]> {
        let randomCategories: Observable<[Category]> = moc.rx.entities(Category.self).map { categories in
            let effectiveCount = min(count, categories.count)
            let randomSlice = categories.shuffled()[0..<effectiveCount]
            return Array(randomSlice)
        }

        return randomCategories.map { categories in
            return categories.map(CategoryViewModel.init)
        }
    }

}
