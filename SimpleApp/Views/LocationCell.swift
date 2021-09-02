//
//  LocationCell.swift
//  SimpleApp
//
//  Created by Mikhail Dudarev on 02.09.2021.
//

import SwiftUI

struct LocationCell: View {
    @EnvironmentObject var viewModel: AppViewModel
    let location: Location?
    
    var body: some View {
        GeometryReader { geometry in
            if let location = location {
                ZStack(alignment: .topLeading) {
                    imageView(for: location, in: geometry)
                    textView(for: location, in: geometry)
                }
            } else {
                loadingCell(in: geometry)
            }
        }
        .clipped()
    }
    
    func loadingCell(in geometry: GeometryProxy) -> some View {
        Text("Loading…")
            .position(x: geometry.size.width / 2.0, y: geometry.size.height / 2.0)
    }
    
    @ViewBuilder
    func imageView(for location: Location, in geometry: GeometryProxy) -> some View {
        if let image = viewModel.imageForLocation(location) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .position(x: geometry.size.width / 2.0, y: geometry.size.height / 2.0)
        } else {
            Rectangle()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .foregroundColor(Color(white: 0.65))
        }
        
    }
    
    func textView(for location: Location, in geometry: GeometryProxy) -> some View {
        Text(location.name)
            .foregroundColor(.white)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 2)
            
            .background(RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(Color(white: 0, opacity: 0.25)))
            .padding(7)
    }
}

struct LocationCell_Loading: PreviewProvider {
    static var previews: some View {
        LocationCell(location: nil)
            .environmentObject(AppViewModel.preview)
            .previewLayout(.fixed(width: 300, height: 100))
    }
}

struct LocationCell_WithImage: PreviewProvider {
    static var previews: some View {
        LocationCell(location: AppViewModel.preview.locations[1])
            .environmentObject(AppViewModel.preview)
            .previewLayout(.fixed(width: 300, height: 100))
    }
}

struct LocationCell_WithoutImage: PreviewProvider {
    static var previews: some View {
        LocationCell(location: Location(
            id: 1,
            name: "Библиотека Аалто",
            imagePath: "NonExistingImagePath"
        ))
        .environmentObject(AppViewModel.preview)
        .previewLayout(.fixed(width: 300, height: 100))
    }
}
