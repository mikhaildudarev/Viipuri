//
//  ImageCache.swift
//  Viipuri
//
//  Created by Mikhail Dudarev on 02.09.2021.
//

import SwiftUI

enum ImageCacheError: Error {
    case badData
}

protocol ImageCache {
    func image(for url: URL) -> Image?
    func insertImage(with data: Data, for url: URL) throws
    func removeImage(for url: URL)
    func clear()
}

final class ImageCacheImpl: ImageCache {
    private lazy var cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        
        // costs are not covered in the simple demo, but worth to be researched for real-life apps
        // cache.countLimit = 100
        // cache.totalCostLimit = 1024 * 1024 * 100 // 100 Mb
        
        return cache
    }()
    
    func image(for url: URL) -> Image? {
        guard let image = cache.object(forKey: url as NSURL) else { return nil }
        return Image(uiImage: image)
    }
    
    func insertImage(with data: Data, for url: URL) throws {
        guard let image = UIImage(data: data) else { throw ImageCacheError.badData }
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func removeImage(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}
