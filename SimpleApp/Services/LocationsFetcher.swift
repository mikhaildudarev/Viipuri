//
//  LocationsFetcher.swift
//  SimpleApp
//
//  Created by Mikhail Dudarev on 02.09.2021.
//

import Foundation
import Combine

enum LocationsFetcherError: Error {
    case badResponse(URLResponse)
    case other(Error)
    
    init(_ error: Error) {
        self = error as? Self ?? .other(error)
    }
}

protocol LocationsFetcher {
    func fetch(url: URL) -> AnyPublisher<Locations, LocationsFetcherError>
}

final class LocationsFetcherImpl: LocationsFetcher {
    let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetch(url: URL) -> AnyPublisher<Locations, LocationsFetcherError> {
        urlSession.dataTaskPublisher(for: url).tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw LocationsFetcherError.badResponse(response)
            }
            
            return data
        }
        .decode(type: Locations.self, decoder: JSONDecoder())
        .mapError { LocationsFetcherError($0) }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

final class PreviewLocationsFetcher: LocationsFetcher {
    func fetch(url: URL) -> AnyPublisher<Locations, LocationsFetcherError> {
        // TODO: use Just to publish test assets
        Empty<Locations, LocationsFetcherError>()
            .eraseToAnyPublisher()
    }
}
