//
//  StubGenerator.swift
//  MVVMPlaygroundTests
//
//  Created by Seyhun Akyürek on 11/11/2018.
//  Copyright © 2018 sakyurek. All rights reserved.
//

import Foundation
import XCTest
@testable import MVVMPlayground

class StubGenerator {
    func stubPhotos() -> [Photo] {
        let path = Bundle.main.path(forResource: "content", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let photos = try! decoder.decode(Photos.self, from: data)
        return photos.photos
    }
}
