//
//  KeychainLayerTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 1/21/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import XCTest
import Pelican

class KeychainLayerTests: XCTestCase {
    
    private let intPersistence = KeychainRepository<Int>.init(keychainWrapper: .default, key: "test")
    
    private let doublePersistence = KeychainRepository<Double>.init(keychainWrapper: .default, key: "test")
    
    override func setUp() {
        intPersistence.empty()
        doublePersistence.empty()
    }
    
    func testSave() {
        let value = 1
        XCTAssertTrue(intPersistence.save(object: value))
        XCTAssertFalse(intPersistence.fetchAll.isEmpty)
    }
    
    func testRemove() {
        let value = 1
        XCTAssertTrue(intPersistence.save(object: value))
        XCTAssertFalse(intPersistence.fetchAll.isEmpty)
        XCTAssertTrue(intPersistence.delete(object: value))
        XCTAssertTrue(intPersistence.fetchAll.isEmpty)
    }
    
    func testErrorWhileSaving() {
        let value = Double.infinity
        XCTAssertFalse(doublePersistence.save(object: value))
    }
    
    func testRetrieveFirstError() {
        XCTAssertTrue(intPersistence.isEmpty)
        XCTAssertNil(intPersistence.first)
    }
    
    func testRetrieveFirst() {
        let value = 1
        XCTAssertTrue(intPersistence.save(object: value))
        XCTAssertFalse(intPersistence.isEmpty)
        XCTAssertNotNil(intPersistence.first)
        XCTAssertEqual(intPersistence.first, 1)
    }
    
}
