//
//  ImageProvider.swift
//  Viipuri
//
//  Created by Mikhail Dudarev on 02.09.2021.
//

import SwiftUI
import Combine

enum ImageLoadingError: Error {
    case badResponse(URLResponse)
    case other(Error)
    
    init(_ error: Error) {
        self = error as? ImageLoadingError ?? .other(error)
    }
}

protocol ImageProvider {
    var delegate: ImageProviderDelegate? { get set }
    func imageForPath(_ path: String) -> Image?
}

protocol ImageProviderDelegate: class {
    func imageProviderDidLoadImageForPath(_ path: String)
}

class ImageProviderImpl: ImageProvider {
    let urlSession: URLSession
    let imageCache: ImageCache
    weak var delegate: ImageProviderDelegate?
    
    private var requests = [String:AnyCancellable]()
    
    init(urlSession: URLSession = .shared, imageCache: ImageCache) {
        self.urlSession = urlSession
        self.imageCache = imageCache
    }
    
    func imageForPath(_ path: String) -> Image? {
        if let url = URL(string: path), let image = imageCache.image(for: url) {
            return image
        }
        
        guard requests[path] == nil, let imageURL = URL(string: path) else {
            return nil
        }
        
        requests[path] = loadImageData(from: imageURL).sink {
            completion in self.requests[path] = nil
        } receiveValue: { _ in }
        
        return nil
    }
    
    private func loadImageData(from url: URL) -> AnyPublisher<Data, ImageLoadingError> {
        urlSession.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw ImageLoadingError.badResponse(response)
                }
                
                return data
            }
            .mapError { ImageLoadingError($0) }
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { imageData in
                do {
                    try self.imageCache.insertImage(with: imageData, for: url)
                    self.delegate?.imageProviderDidLoadImageForPath(url.absoluteString)
                } catch {
                    print("Failed to insert an image to cache:\n\(error)")
                }
            })
            .eraseToAnyPublisher()
    }
}

class PreviewImageProvider: ImageProvider {
    weak var delegate: ImageProviderDelegate?
    
    func imageForPath(_ path: String) -> Image? {
        return Image(path)
    }
}
