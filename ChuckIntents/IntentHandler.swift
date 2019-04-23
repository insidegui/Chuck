//
//  IntentHandler.swift
//  ChuckIntents
//
//  Created by Guilherme Rambo on 23/04/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        return TellJokeIntentHandler()
    }
    
}
