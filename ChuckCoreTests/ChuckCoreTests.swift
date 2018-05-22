//
//  ChuckCoreTests.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import XCTest
@testable import ChuckCore

class ChuckCoreTests: XCTestCase {

    /// Make sure all required resources are available for the tests, this test will fail if any
    /// of the required resources is not available in the test bundle
    func testBundleIntegrity() throws {
        try TestResource.all.forEach { _ = try Bundle.testBundle.fetch(resource: $0) }
    }
    
}
