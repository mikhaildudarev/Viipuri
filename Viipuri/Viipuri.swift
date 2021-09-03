//
//  Viipuri.swift
//  Viipuri
//
//  Created by Mikhail Dudarev on 31.08.2021.
//

import SwiftUI

@main
struct Viipuri: App {
    @StateObject var viewModel = AppViewModel(
        downloder: LocationsFetcherImpl(),
        imageProvider: ImageProviderImpl(imageCache: ImageCacheImpl()))
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear { viewModel.updateLocations() }
        }
    }
}
