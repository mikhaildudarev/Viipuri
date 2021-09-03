//
//  Location.swift
//  Viipuri
//
//  Created by Mikhail Dudarev on 02.09.2021.
//

import Foundation
import SwiftUI

struct Locations: Decodable {
    let locations: [Location]
}

struct Location: Decodable, Identifiable {
    let id: Int
    let name: String
    let imagePath: String
    var isLoading = false
    
    // TODO: read more about asymmetric encoding / decoding
    private enum CodingKeys: String, CodingKey {
        case id, name, imagePath
    }
    
    static var loadingLocation: Location {
        var location = Location(id: 0, name: "", imagePath: "")
        location.isLoading = true
        return location
    }
}
