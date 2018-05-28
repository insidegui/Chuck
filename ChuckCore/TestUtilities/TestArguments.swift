//
//  TestArguments.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

public final class TestArguments {

    public static var isRunningUITests: Bool {
        return ProcessInfo.processInfo.arguments.contains("--uitests")
    }

}
