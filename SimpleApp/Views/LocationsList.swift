//
//  LocationsList.swift
//  SimpleApp
//
//  Created by Mikhail Dudarev on 02.09.2021.
//

import SwiftUI

struct LocationsList: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.locations) { location in
                LocationCell(location: location.isLoading ? nil : location)
                    .frame(height: 180)
            }.listRowInsets(EdgeInsets())
        }
        .navigationBarHidden(true)
    }
}

struct LocationsList_Loaded: PreviewProvider {
    static var previews: some View {
        LocationsList()
            .environmentObject(AppViewModel.preview)
    }
}

struct LocationsList_Loading: PreviewProvider {
    static var previews: some View {
        LocationsList()
            .environmentObject(AppViewModel.preview(isLoading: true))
    }
}
