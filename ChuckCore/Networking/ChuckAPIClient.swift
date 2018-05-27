//
//  ChuckAPIClient.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public enum APIResult<T> {
    case success(T)
    case error(Error)
}

public final class ChuckAPIClient {

    private struct Constants {
        static let maxRetryCount = 3
    }

    public enum APIError: Error {
        case requestGeneration
    }

    public let environment: ChuckAPIEnvironment

    public init(environment: ChuckAPIEnvironment = .production) {
        self.environment = environment
    }

    private lazy var session: URLSession = {
        return URLSession(configuration: .default)
    }()

    private func localFileObservable(with url: URL?) -> Observable<Data> {
        guard let url = url else { return Observable.error(APIError.requestGeneration) }

        do {
            let data = try Data(contentsOf: url)

            return Observable.just(data)
        } catch {
            return Observable.error(error)
        }
    }

    private func observable<T: Codable>(for endpoint: ChuckAPIEndpoint<T>, responseType: T.Type) -> Observable<T> {
        guard let request = endpoint.request else {
            return Observable.error(APIError.requestGeneration)
        }

        let dataObservable: Observable<Data>

        if request.url?.isFileURL == true {
            // File URLs are used during testing, so we skip URLSession altogether in this case
            dataObservable = localFileObservable(with: request.url)
        } else {
            dataObservable = session.rx.data(request: request)
        }

        return dataObservable.map { data in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(responseType, from: data)
        }
    }

    public lazy var random: Observable<Joke> = {
        return self.observable(for: .random(environment: self.environment), responseType: Joke.self)
    }()

    public func random(with category: Category) -> Observable<Joke> {
        return observable(for: .random(with: category.name, environment: self.environment), responseType: Joke.self)
    }

    public func random(with categoryName: String) -> Observable<Joke> {
        return observable(for: .random(with: categoryName, environment: self.environment), responseType: Joke.self)
    }

    public lazy var categories: Observable<[ChuckCore.Category]> = {
        return self.observable(for: .categories(environment: self.environment), responseType: [ChuckCore.Category].self)
    }()

    public func search(with term: String) -> Observable<SearchResponse> {
        return observable(for: .search(with: term, environment: self.environment), responseType: SearchResponse.self)
    }

}
