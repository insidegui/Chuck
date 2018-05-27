//
//  ChuckAPIClient.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import RxSwift

public enum APIResult<T> {
    case success(T)
    case error(Error)
}

public final class ChuckAPIClient {

    private lazy var session: URLSession = {
        return URLSession(configuration: .default)
    }()

}
