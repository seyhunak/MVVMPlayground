//
//  APIServiceTests.swift
//  MVVMPlaygroundTests
//
//  Created by sakyurek on 01/10/2017.
//  Copyright © 2018 Seyhun Akyürek. All rights reserved.
//

import XCTest
@testable import MVVMPlayground

class APIServiceTests: XCTestCase {
    
    var service: APIService?
    
    override func setUp() {
        super.setUp()
        service = APIService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func test_fetch_popular_photos() {

        let service = self.service!
        let expect = XCTestExpectation(description: "callback")

        service.fetchPopularPhoto(complete: { (success, photos, error) in
            expect.fulfill()
            XCTAssertEqual( photos.count, 20)
            
            for photo in photos {
                XCTAssertNotNil(photo.id)
            }
            
        })

        wait(for: [expect], timeout: 3.1)
    }
    
}
