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

    private lazy var syncEngine: SyncEngine = {
        let client = ChuckAPIClient(environment: .production)
        return SyncEngine(client: client, persistentContainer: persistentContainer)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = AppFlowController(syncEngine: syncEngine)

        window?.makeKeyAndVisible()

        syncCategories()

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

}

