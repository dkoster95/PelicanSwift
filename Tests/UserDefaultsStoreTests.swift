//
//  UserDefaultsLayerTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 1/21/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import XCTest
import Pelican

class UserDefaultsStoreTests: XCTestCase {
    
    private let sut = UserDefaultsStore(userDefaults: .standard)
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    override func setUp() {
        _ = sut.delete(key: "test")
    }
    
    func test_save_whenNoError_expectSuccess() throws {
        let value = 1
        XCTAssertNil(sut.fetch(key: "test"))
        let encodedValue = try jsonEncoder.encode(value)
        
        let result = sut.save(data: encodedValue, key: "test")
        
        XCTAssertTrue(result)
    }
    
    func test_delete_whenValue_expectElementDeleted() throws {
        let value = 1
        XCTAssertNil(sut.fetch(key: "test"))
        let encodedValue = try jsonEncoder.encode(value)
        let resultSave = sut.save(data: encodedValue, key: "test")
        let resultFetchSaved = sut.fetch(key: "test")
        
        let resultDelete = sut.delete(key: "test")
        let resultFetch = sut.fetch(key: "test")
        
        XCTAssertTrue(resultSave)
        XCTAssertNotNil(resultFetchSaved)
        XCTAssertTrue(resultDelete)
        XCTAssertNil(resultFetch)
    }
    
    func test_update_whenValueExists_expectValueUpdated() throws {
        let value = 1
        let updatedValue = 3
        XCTAssertNil(sut.fetch(key: "test"))
        let encodedValue = try jsonEncoder.encode(value)
        let encodedUpdatedValue = try jsonEncoder.encode(updatedValue)
        
        let resultSave = sut.save(data: encodedValue, key: "test")
        let resultUpdate = sut.update(data: encodedUpdatedValue, key: "test")
        let resultFetch = try jsonDecoder.decode(Int.self, from: sut.fetch(key: "test")!)
        
        XCTAssertTrue(resultSave)
        XCTAssertTrue(resultUpdate)
        XCTAssertEqual(3, resultFetch)
    }
    
    func test_update_whenValueDoesNotExists_expectValueCreated() throws {
        let updatedValue = 3
        XCTAssertNil(sut.fetch(key: "test"))
        let encodedUpdatedValue = try jsonEncoder.encode(updatedValue)
        
        let resultUpdate = sut.update(data: encodedUpdatedValue, key: "test")
        let resultFetch = try jsonDecoder.decode(Int.self, from: sut.fetch(key: "test")!)
        
        XCTAssertTrue(resultUpdate)
        XCTAssertEqual(3, resultFetch)
    }
    
}
