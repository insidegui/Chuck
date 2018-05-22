//
//  DecodingErrorExtension.swift
//  ChuckCoreTests
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

extension Error {

    var decodingErrorPrettyDescription: String {
        guard let effectiveError = self as? DecodingError else { return "" }

        let errorInfo: String
        let errorContext: DecodingError.Context

        switch effectiveError {
        case .dataCorrupted(let ctx):
            errorInfo = "Invalid data."
            errorContext = ctx
        case .keyNotFound(let key, let ctx):
            errorInfo = "Key not found: \(key)."
            errorContext = ctx
        case .typeMismatch(let expectedType, let ctx):
            errorInfo = "Invalid type found. Expected \(expectedType)."
            errorContext = ctx
        case .valueNotFound(let expectedType, let ctx):
            errorInfo = "Value not found and the key is not optional. Expected type \(expectedType)."
            errorContext = ctx
        }

        let underlyingInfo = errorContext.underlyingError?.localizedDescription ?? ""

        return """
               Error converting JSON to Codable type: \(errorInfo).
               Path: \(errorContext.codingPath).
               Underlying error: \(underlyingInfo).
               """
    }

}
