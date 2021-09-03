//
//  ViewModel.swift
//  Viipuri
//
//  Created by Mikhail Dudarev on 31.08.2021.
//

import SwiftUI
import Combine

final class AppViewModel: ObservableObject, ImageProviderDelegate {
    let locationsFetcher: LocationsFetcher
    var imageProvider: ImageProvider
    
    var fetchingLocationsCancellable: AnyCancellable?
    
    @Published var locations = (0...10).map { _ in Location.loadingLocation }
    
    init(downloder: LocationsFetcher, imageProvider: ImageProvider) {
        self.locationsFetcher = downloder
        self.imageProvider = imageProvider
        self.imageProvider.delegate = self
    }
    
    func updateLocations() {
        let url = URL(string: "http://127.0.0.1:8000/locations.json")!
        fetchingLocationsCancellable = locationsFetcher.fetch(url: url).sink { completion in
            switch completion {
            case .finished: print("Downloaded locations")
            case .failure(let error): print("Failed to download locations:\n\(error)")
            }
        } receiveValue: { result in
            self.locations = result.locations
        }
    }
    
    func imageForLocation(_ location: Location) -> Image? {
        guard let image = imageProvider.imageForPath(location.imagePath) else {
            return nil
        }
        
        return image
    }
    
    func imageProviderDidLoadImageForPath(_ path: String) {
        guard locations.contains(where: { $0.imagePath == path }) else { return }
        objectWillChange.send()
    }
}

extension AppViewModel {
    static var preview: AppViewModel {
        preview(isLoading: false)
    }
    
    static func preview(isLoading: Bool) -> AppViewModel {
        let viewModel = AppViewModel(
            downloder: PreviewLocationsFetcher(),
            imageProvider: PreviewImageProvider())
        
        if !isLoading {
            viewModel.locations = viewModel.loadLocations()
        }
        
        return viewModel
    }
    
    func loadLocations() -> [Location] {
        guard let asset = NSDataAsset(name: "locations_preview.json", bundle: Bundle.main) else {
            fatalError("Couldn't load locations JSON in the main bundle")
        }
        
        do {
            let locations = try JSONDecoder().decode(Locations.self, from: asset.data)
            return locations.locations
        } catch {
            fatalError("Couldn't parse locations JSON in the main bundle:\n\(error)")
        }
    }
}
