//
//  PhotoListViewModelTests.swift
//  MVVMPlaygroundTests
//
//  Created by sakyurek on 11/10/2018.
//  Copyright © 2018 Seyhun Akyürek. All rights reserved.
//

import XCTest
@testable import MVVMPlayground

class PhotoListViewModelTests: XCTestCase {
    
    var viewModel: PhotoListViewModel!
    var mockAPIService: MockApiService!

    override func setUp() {
        super.setUp()
        mockAPIService = MockApiService()
        viewModel = PhotoListViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    func test_fetch_photo() {
        mockAPIService.completePhotos = [Photo]()
        viewModel.initFetch()
        XCTAssert(mockAPIService!.isFetchPopularPhotoCalled)
    }
    
    func test_fetch_photo_fail() {
        let error = APIError.permissionDenied
        
        viewModel.initFetch()
        mockAPIService.fetchFail(error: error )
        XCTAssertEqual( viewModel.alertMessage, error.rawValue )

    }
    
    func test_create_cell_view_model() {
        let photos = StubGenerator().stubPhotos()
        mockAPIService.completePhotos = photos
        let expect = XCTestExpectation(description: "reload closure triggered")
        viewModel.reloadTableViewClosure = { () in
            expect.fulfill()
        }
        
        viewModel.initFetch()
        mockAPIService.fetchSuccess()
        
        XCTAssertEqual(viewModel.numberOfCells, photos.count)
        wait(for: [expect], timeout: 1.0)
        
    }
    
    func test_loading_when_fetching() {
        var loadingStatus = false
        let expect = XCTestExpectation(description: "Loading status updated")
        viewModel.updateLoadingStatus = { [weak viewModel] in
            loadingStatus = viewModel!.isLoading
            expect.fulfill()
        }
        
        viewModel.initFetch()
        
        XCTAssertTrue( loadingStatus )
        mockAPIService!.fetchSuccess()
        XCTAssertFalse( loadingStatus )
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_user_press_for_sale_item() {
        
        let indexPath = IndexPath(row: 0, section: 0)
        goToFetchPhotoFinished()

        viewModel.userPressed( at: indexPath )
        
        XCTAssertTrue(viewModel.isAllowSegue)
        XCTAssertNotNil(viewModel.selectedPhoto)
        
    }
    
    func test_user_press_not_for_sale_item() {
        
        let indexPath = IndexPath(row: 2, section: 0)
        goToFetchPhotoFinished()
        
        let testPhoto = mockAPIService.completePhotos[indexPath.row]

        let expect = XCTestExpectation(description: "Alert message is shown")
        viewModel.showAlertClosure = { [weak viewModel] in
            expect.fulfill()
            XCTAssertEqual(viewModel!.alertMessage, self.showAlertMessage(photo: testPhoto))
        }
        
        viewModel.userPressed( at: indexPath )
        
        XCTAssertFalse(viewModel.isAllowSegue)
        XCTAssertNil(viewModel.selectedPhoto)
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_get_cell_view_model() {
        
        goToFetchPhotoFinished()
        
        let indexPath = IndexPath(row: 1, section: 0)
        let testPhoto = mockAPIService.completePhotos[indexPath.row]
        let vm = viewModel.getCellViewModel(at: indexPath)
        
        XCTAssertEqual( vm.titleText, testPhoto.name)
        
    }
    
    func test_cell_view_model() {
        let today = Date()
        let photo = Photo(id: 1, name: "Name", description: "desc", created_at: today, image_url: "url", for_sale: true, camera: "camera")
        let photoWithoutCarmera = Photo(id: 1, name: "Name", description: "desc", created_at: Date(), image_url: "url", for_sale: true, camera: nil)
        let photoWithoutDesc = Photo(id: 1, name: "Name", description: nil, created_at: Date(), image_url: "url", for_sale: true, camera: "camera")
        let photoWithouCameraAndDesc = Photo(id: 1, name: "Name", description: nil, created_at: Date(), image_url: "url", for_sale: true, camera: nil)
        
        let cellViewModel = viewModel!.createCellViewModel( photo: photo )
        let cellViewModelWithoutCamera = viewModel!.createCellViewModel( photo: photoWithoutCarmera )
        let cellViewModelWithoutDesc = viewModel!.createCellViewModel( photo: photoWithoutDesc )
        let cellViewModelWithoutCameraAndDesc = viewModel!.createCellViewModel( photo: photoWithouCameraAndDesc )
        
        XCTAssertEqual( photo.name, cellViewModel.titleText )
        XCTAssertEqual( photo.image_url, cellViewModel.imageUrl )
        XCTAssertEqual(cellViewModel.descText, "\(photo.camera!) - \(photo.description!)" )
        XCTAssertEqual(cellViewModelWithoutDesc.descText, photoWithoutDesc.camera! )
        XCTAssertEqual(cellViewModelWithoutCamera.descText, photoWithoutCarmera.description! )
        XCTAssertEqual(cellViewModelWithoutCameraAndDesc.descText, "" )
        
        let year = Calendar.current.component(.year, from: today)
        let month = Calendar.current.component(.month, from: today)
        let day = Calendar.current.component(.day, from: today)
        
        XCTAssertEqual( cellViewModel.dateText, String(format: "%d-%02d-%02d", year, month, day) )
        
    }
}

//MARK: State control

extension PhotoListViewModelTests {
    private func goToFetchPhotoFinished() {
        mockAPIService.completePhotos = StubGenerator().stubPhotos()
        viewModel.initFetch()
        mockAPIService.fetchSuccess()
    }
    
    private func showAlertMessage(photo: Photo) -> String {
        return "\(photo.name) is not available for sale!"
    }
}

class MockApiService: APIServiceProtocol {
    
    var isFetchPopularPhotoCalled = false
    var completePhotos: [Photo] = [Photo]()
    var completeClosure: ((Bool, [Photo], APIError?) -> ())!
    
    func fetchPopularPhoto(complete: @escaping (Bool, [Photo], APIError?) -> ()) {
        isFetchPopularPhotoCalled = true
        completeClosure = complete
    }
    
    func fetchSuccess() {
        completeClosure( true, completePhotos, nil )
    }
    
    func fetchFail(error: APIError?) {
        completeClosure( false, completePhotos, error )
    }
    
}


