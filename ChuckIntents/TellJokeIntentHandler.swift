//
//  TellJokeIntentHandler.swift
//  ChuckIntents
//
//  Created by Guilherme Rambo on 23/04/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Foundation
import RxSwift
import ChuckCore
import os.log

final class TellJokeIntentHandler: NSObject, TellJokeIntentHandling {

    private let log = OSLog(subsystem: "ChuckIntents", category: "TellJokeIntentHandler")

    private let uiStack = ChuckUIStack()

    private let bag = DisposeBag()

    func handle(intent: TellJokeIntent, completion: @escaping (TellJokeIntentResponse) -> Void) {
        os_log("%{public}@", log: log, type: .debug, #function)

        uiStack.syncEngine.randomJoke().observeOn(MainScheduler.instance).bind { [weak self] joke in
            guard let self = self else { return }

            os_log("Fetched joke: %{public}@", log: self.log, type: .default, String(describing: joke))

            let response = TellJokeIntentResponse(code: .success, userActivity: nil)

            response.body = joke.body

            completion(response)
        }.disposed(by: bag)
    }

}
