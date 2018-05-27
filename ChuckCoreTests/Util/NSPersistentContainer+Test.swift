//
//  NSPersistentContainer+Test.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import CoreData
@testable import ChuckCore

extension NSPersistentContainer {

    static var test: NSPersistentContainer {
        guard let url = Bundle.chuckCore.url(forResource: "Model", withExtension: "momd") else {
            fatalError("Failed to find Model.momd in ChuckCore")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load managed object model from ChuckCore")
        }

        let persistentContainer = NSPersistentContainer(name: "Model", managedObjectModel: model)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Error loading persistent stores: \(error.localizedDescription)")
            }
        })

        return persistentContainer
    }

}
