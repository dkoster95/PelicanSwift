//
//  KeychainLayerTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 1/21/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import XCTest
import Pelican

class KeyValueRepositoryTests: XCTestCase {
    
    private var sut: KeyValueRepository<MockEntity>!
    private let mockStore = MockStore()
    
    override func setUp() {
        sut = KeyValueRepository<MockEntity>(key: "test",
                                             store: mockStore,
                                             jsonEncoder: JSONEncoder(),
                                             jsonDecoder: JSONDecoder())
        sut.empty()
    }
    
    func test_save_whenEncodingFails_expectErrorThrown() {
        let testEntity = MockEntity(parameter: "param", number: Double.infinity)
        
        XCTAssertThrowsError(try sut.save(element: testEntity))
    }
    
    func test_save_whenDataIsSaved_expectRetured() throws {
        let testEntity = MockEntity(parameter: "param", number: 12)
        
        let result = try sut.save(element: testEntity)
        
        XCTAssertEqual(testEntity, result)
    }
    
    func test_update_whenEncodingFails_expectErrorThrown() {
        let testEntity = MockEntity(parameter: "param", number: Double.infinity)
        
        XCTAssertThrowsError(try sut.update(element: testEntity))
    }
}

private struct MockEntity: Codable, Equatable {
    let parameter: String
    let number: Double
}
private func == (lhs: MockEntity, rhs: MockEntity) -> Bool {
    return lhs.parameter == rhs.parameter && lhs.number == rhs.number
}

private class MockStore: KeyValueStore {
    
    var didSave = false
    func save(data: Data, key: String) -> Bool {
        didSave = true
        return didSave
    }
    var didUpdate = false
    func update(data: Data, key: String) -> Bool {
        didUpdate = true
        return didUpdate
    }
    
    var didDelete = false
    func delete(key: String) -> Bool {
        didDelete = true
        return didDelete
    }
    
    var didFetch = false
    func fetch(key: String) -> Data? {
        didFetch = true
        return Data()
    }
}
