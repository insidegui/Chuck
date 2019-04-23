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

import Intents

extension Notification.Name {
    static let ChuckErrorDidOccur = Notification.Name("ChuckErrorDidOccur")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let log = OSLog(subsystem: "Chuck", category: "AppDelegate")

    var window: UIWindow?

    private let uiStack = ChuckUIStack()

    private lazy var flowController: AppFlowController = {
        return AppFlowController(syncEngine: uiStack.syncEngine)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        resetStorageIfRunningUITests()

        configureReachability()

        window = UIWindow()
        window?.rootViewController = flowController

        window?.makeKeyAndVisible()

        syncCategories()

        if #available(iOS 12.0, *) {
            registerShortcutSuggestions()
        }

        return true
    }

    private let disposeBag = DisposeBag()

    private func configureReachability() {
        do {
            try uiStack.reachability.startNotifier()
        } catch {
            os_log("Failed to start reachability: %{public}@", log: self.log, type: .error, String(describing: error))
        }

        // Sets isOffline to true in the flow controller whenever reachability is not connected
        uiStack.reachability.rx.isReachable.map({ !$0 }).bind(to: flowController.isOffline).disposed(by: disposeBag)
    }

    private func syncCategories() {
        uiStack.syncEngine.syncCategories().subscribeOn(MainScheduler.instance).subscribe(onError: { [weak self] error in
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
            try uiStack.syncEngine.clearDatabase()
        } catch {
            fatalError(String(describing: error))
        }
    }

    @available(iOS 12.0, *)
    private func registerShortcutSuggestions() {
        let intent = TellJokeIntent()
        intent.suggestedInvocationPhrase = "Tell me a Chuck joke"

        guard let shortcut = INShortcut(intent: intent) else {
            os_log("Failed to register shortcut suggestions!", log: self.log, type: .fault)
            return
        }

        INVoiceShortcutCenter.shared.setShortcutSuggestions([shortcut])

        os_log("Registered shortcut suggestions", log: self.log, type: .default)
    }

}
