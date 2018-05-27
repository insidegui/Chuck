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

    // MARK: - Jokes

    /// Syncs search results from the API for the provided term
    ///
    /// - Parameter term: the term to search for
    /// - Returns: An Observable that can be used to check for completion and errors
    public func syncSearchResults(with term: String) -> Observable<Void> {
        return client.search(with: term).do(onNext: { [unowned self] response in
            try response.result.forEach(self.moc.rx.update)
        }).map { _ in Void() }
    }

    /// Performs a fetch on the database for jokes matching the term specified
    ///
    /// - Parameter term: the term to search for
    /// - Returns: all jokes matching the specified term
    public func fetchSearchResults(with term: String) -> Observable<[JokeViewModel]> {
        let predicate = NSPredicate(format: "value CONTAINS[cd] %@", term)

        return moc.rx.entities(Joke.self, predicate: predicate).map { jokes in
            return jokes.map(JokeViewModel.init)
        }
    }

    /// Performs a search on the API for a random joke
    /// The result is also persisted to the local database
    ///
    /// - Returns: An Observable with a random joke fresh from the API
    public func randomJoke() -> Observable<JokeViewModel> {
        return client.random.do(onNext: { [unowned self] joke in
            try self.moc.rx.update(joke)
        }).map(JokeViewModel.init)
    }

    /// Performs a search on the API for a random joke with the specified category
    /// The result is also persisted to the local database
    ///
    /// - Parameter categoryName: the category name to get a random joke for
    /// - Returns: An Observable with a random joke in the specified category fresh from the API
    public func randomJoke(with categoryName: String) -> Observable<JokeViewModel> {
        return client.random(with: categoryName).do(onNext: { [unowned self] joke in
            try self.moc.rx.update(joke)
        }).map(JokeViewModel.init)
    }

    /// Performs a fetch on the database and returns a random selection of jokes
    ///
    /// - Parameter count: the number of jokes to fetch
    /// - Returns: An observable with a random selection of jokes with the amount specified (limited by the number of jokes available)
    public func fetchRandomJokes(with count: Int) -> Observable<[JokeViewModel]> {
        let randomJokes: Observable<[Joke]> = moc.rx.entities(Joke.self).map { jokes in
            return jokes.randomSelection(with: count)
        }

        return randomJokes.map { jokes in
            return jokes.map(JokeViewModel.init)
        }
    }

    // MARK: - Categories

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
    /// - Returns: An observable with a random selection of categories with the amount specified (limited by the number of categories available)
    public func fetchRandomCategories(with count: Int = 8) -> Observable<[CategoryViewModel]> {
        let randomCategories: Observable<[Category]> = moc.rx.entities(Category.self).map { categories in
            return categories.randomSelection(with: count)
        }

        return randomCategories.map { categories in
            return categories.map(CategoryViewModel.init)
        }
    }

}
