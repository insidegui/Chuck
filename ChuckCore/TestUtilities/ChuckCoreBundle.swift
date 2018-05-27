//
//  ChuckCoreBundle.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

private final class _StubForBundleInitialization { }

extension Bundle {

    static let chuckCore: Bundle = {
        return Bundle(for: _StubForBundleInitialization.self)
    }()

}
