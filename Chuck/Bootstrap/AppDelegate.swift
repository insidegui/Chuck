//
//  AppDelegate.swift
//  Chuck
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit
import ChuckCore
import CoreData
import RxSwift
import Reachability
import os.log

extension Notification.Name {
    static let ChuckErrorDidOccur = Notification.Name("ChuckErrorDidOccur")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let log = OSLog(subsystem: "Chuck", category: "AppDelegate")

    var window: UIWindow?

    private lazy var persistentContainer: NSPersistentContainer = {
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

    private lazy var reachability: Reachability = {
        guard let instance = Reachability(hostname: "api.chucknorris.io") else {
            fatalError("Unable to instantiate reachability instance")
        }

        return instance
    }()

    private lazy var syncEngine: SyncEngine = {
        let env: ChuckAPIEnvironment = TestArguments.isRunningUITests ? .test : .production

        let client = ChuckAPIClient(environment: env)

        return SyncEngine(
            client: client,
            persistentContainer: persistentContainer,
            reachability: reachability
        )
    }()

    private lazy var flowController: AppFlowController = {
        return AppFlowController(syncEngine: syncEngine)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        resetStorageIfRunningUITests()

        window = UIWindow()
        window?.rootViewController = flowController

        window?.makeKeyAndVisible()

        syncCategories()

        // Sets isOffline to true in the flow controller whenever reachability is not connected
        reachability.rx.isReachable.map({ !$0 }).bind(to: flowController.isOffline).disposed(by: disposeBag)

        return true
    }

    private let disposeBag = DisposeBag()

    private func syncCategories() {
        syncEngine.syncCategories().subscribeOn(MainScheduler.instance).subscribe(onError: { [weak self] error in
            guard let `self` = self else { return }

            os_log(
                "Failed to sync categories: %{public}@",
                log: self.log,
                type: .error,
                String(describing: error)
            )

            NotificationCenter.default.post(name: .ChuckErrorDidOccur, object: error)
        }, onCompleted: { [weak self] in
            guard let `self` = self else { return }

            os_log("Synced categories", log: self.log, type: .info)
        }).disposed(by: disposeBag)
    }

    private func resetStorageIfRunningUITests() {
        guard TestArguments.isRunningUITests else { return }
        guard let bundleId = Bundle.main.bundleIdentifier else { return }

        // Clear user defaults
        UserDefaults.standard.removePersistentDomain(forName: bundleId)

        // Clear storage
        do {
            try syncEngine.clearDatabase()
        } catch {
            fatalError(String(describing: error))
        }
    }

}

