//
//  ChuckCorePersistenceTests.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import XCTest
import Foundation

import CoreData
import RxCoreData
import RxBlocking

@testable import ChuckCore

class ChuckCorePersistenceTests: XCTestCase {

    private var persistentContainer: NSPersistentContainer!

    private var moc: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    override func setUp() {
        guard let url = Bundle.chuckCore.url(forResource: "Model", withExtension: "momd") else {
            fatalError("Failed to find Model.momd in ChuckCore")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load managed object model from ChuckCore")
        }

        persistentContainer = NSPersistentContainer(name: "Model", managedObjectModel: model)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Error loading persistent stores: \(error.localizedDescription)")
            }
        })
    }

    /// Ensures the joke's properties are preserved after being persisted and restored from the database
    func testJokePersistenceRoundTrip() throws {
        let joke = try Joke.sample()

        try moc.rx.update(joke)

        let results = try moc.rx.entities(Joke.self).toBlocking().first()

        XCTAssertNotNil(results)
        XCTAssert(results?.count == 1)

        let jokeFromDB = results!.first!

        validateSampleJokeFields(with: jokeFromDB)
    }

    /// Ensures that recent searches are stored and retrieved properly
    func testRecentSearchPersistenceRoundTrip() throws {
        let referenceDate = Date()
        let recentSearch = RecentSearch(term: "Apple", createdAt: referenceDate)

        try moc.rx.update(recentSearch)

        let results = try moc.rx.entities(RecentSearch.self).toBlocking().first()

        XCTAssertNotNil(results)
        XCTAssert(results?.count == 1)
        XCTAssert(results?.first?.term == "Apple")
        XCTAssert(results?.first?.createdAt == referenceDate)
    }

    /// Ensures that searching for the same term repeatedly does not add a new entry to the database for the same search
    func testRecentSearchesAreNotDuplicated() throws {
        let search = RecentSearch(term: "Apple")
        let search2 = RecentSearch(term: "Microsoft")
        let search3 = RecentSearch(term: "Apple")

        try moc.rx.update(search)
        try moc.rx.update(search2)
        try moc.rx.update(search3)

        let results = try moc.rx.entities(RecentSearch.self).toBlocking().first()

        XCTAssertNotNil(results)
        XCTAssert(results?.count == 2)
    }

}
