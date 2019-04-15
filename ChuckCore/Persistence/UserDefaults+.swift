//
//  UserDefaults+.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 15/04/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Foundation

public extension UserDefaults {

    static let chuckApplicationGroup = "group.codes.rambo.Chuck"

    static var groupDefaults: UserDefaults {
        return UserDefaults(suiteName: UserDefaults.chuckApplicationGroup) ?? .standard
    }

}
