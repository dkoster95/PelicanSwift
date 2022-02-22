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
    
    private let sut = KeyValueRepository<Int>(key: "test", store: MockStore(), jsonEncoder: JSONEncoder(), jsonDecoder: JSONDecoder())
    
    override func setUp() {
        sut.empty()
    }
    
    func testSave() {
        let value = 1
        XCTAssertTrue(sut.save(object: value))
    }
    
    func testRemove() {
        let value = 1
        XCTAssertTrue(sut.save(object: value))
        XCTAssertTrue(sut.delete(object: value))
        XCTAssertTrue(sut.fetchAll.isEmpty)
    }
    
    func testRetrieveFirstError() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.first)
    }
    
    func testFetchAllEmpty() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertTrue(sut.fetchAll.isEmpty)
    }
    
    func testUpdateSuccess() {
        XCTAssertTrue(sut.save(object: 1))
        XCTAssertTrue(sut.update(object: 2))
    }
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
