//
//  ChuckUIStack.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 15/04/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Foundation
import CoreData
import Reachability

public final class ChuckUIStack {

    public lazy var persistentContainer: NSPersistentContainer = {
        guard let url = Bundle.chuckCore.url(forResource: "Model", withExtension: "momd") else {
            fatalError("Failed to find Model.momd in ChuckCore")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load managed object model from ChuckCore")
        }

        let persistentContainer = NSPersistentContainer(name: "Model", managedObjectModel: model)

        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("Error loading persistent stores: \(error.localizedDescription)")
            }
        })

        return persistentContainer
    }()

    public lazy var reachability: Reachability = {
        guard let instance = Reachability(hostname: "api.chucknorris.io") else {
            fatalError("Unable to instantiate reachability instance")
        }

        return instance
    }()

    public lazy var syncEngine: SyncEngine = {
        let env: ChuckAPIEnvironment = TestArguments.isRunningUITests ? .test : .production

        let client = ChuckAPIClient(environment: env)

        return SyncEngine(
            client: client,
            persistentContainer: persistentContainer,
            reachability: reachability
        )
    }()

    public init() {
        
    }

}
