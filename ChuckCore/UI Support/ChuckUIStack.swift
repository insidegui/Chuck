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
        return self.makePersistentContainer()
    }()

    private func makePersistentContainer() -> NSPersistentContainer {
        guard let baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: UserDefaults.chuckApplicationGroup) else {
            fatalError("Failed to get container URL for app group identifier \(UserDefaults.chuckApplicationGroup)")
        }

        let storageURL = baseURL.appendingPathComponent("Storage.db")

        do {
            let container = try ChuckCorePersistentContainer(url: storageURL, readOnly: false)

            container.loadPersistentStores(completionHandler: { _, error in
                if let error = error {
                    fatalError("Error loading persistent stores: \(error.localizedDescription)")
                }
            })

            return container
        } catch {
            fatalError("Storage initialization error: \(error)")
        }
    }

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
