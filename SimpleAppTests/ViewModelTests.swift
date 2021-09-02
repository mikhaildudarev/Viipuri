//
//  ViewModelTests.swift
//  SimpleAppTests
//
//  Created by Mikhail Dudarev on 02.09.2021.
//

import XCTest
@testable import SimpleApp

class ViewModelTests: XCTestCase {
    func testLoadingLocationsForPreview() {
        let viewModel = AppViewModel.preview
        XCTAssertEqual(viewModel.locations.count, 7)
        
        for location in viewModel.locations {
            print(location.imagePath)
            XCTAssertNotNil(viewModel.imageForLocation(location))
        }
        
    }
}

