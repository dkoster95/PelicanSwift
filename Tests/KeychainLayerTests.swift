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
        XCTAssertTrue(intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieveFirst(query: nil) {
            result in
            switch result {
            case .success(_ ):
                XCTAssert(false)
            case .failure(let error):
                if let errorP = error as? PelicanRepositoryError {
                    XCTAssertEqual(errorP, PelicanRepositoryError.nonExistingData)
                }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieveFirst() {
        let value = 1
        XCTAssertTrue(intPersistence.save(object: value))
        XCTAssertFalse(intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieveFirst(query: nil) {
            result in
            switch result {
            case .success(let int):
                XCTAssertEqual(value, int)
            case .failure(_ ):
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieveFirstQuery() {
        let value = 1
        XCTAssertTrue(intPersistence.save(object: value))
        XCTAssertFalse(intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieveFirst(query: { $0 == 1}) {
            result in
            switch result {
            case .success(let int):
                XCTAssertEqual(value, int)
            case .failure(_ ):
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieveFirstQueryError() {
        let value = 1
        XCTAssertTrue(intPersistence.save(object: value))
        XCTAssertFalse(intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieveFirst(query: { $0 == 2 }) {
            result in
            switch result {
            case .success(_ ):
                XCTAssert(false)
            case .failure(let error):
                if let errorP = error as? PelicanRepositoryError {
                    XCTAssertEqual(errorP, PelicanRepositoryError.nonExistingData)
                }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieveQueryError() {
        let value = 1
        XCTAssertTrue(intPersistence.save(object: value))
        XCTAssertFalse(intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieve(query: { $0 == 2 }) {
            result in
            switch result {
            case .success(_ ):
                XCTAssert(false)
            case .failure(let error):
                if let errorP = error as? PelicanRepositoryError {
                    XCTAssertEqual(errorP, PelicanRepositoryError.nonExistingData)
                }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieveQuery() {
        let value = 1
        XCTAssertTrue(intPersistence.save(object: value))
        XCTAssertFalse(intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieve(query: { $0 == 1 }) {
            result in
            switch result {
            case .success(let value):
                XCTAssert(value.count == 1)
            case .failure(_ ):
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieve() {
        let value = 1
        XCTAssertTrue(intPersistence.save(object: value))
        XCTAssertFalse(intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieve(query: nil) {
            result in
            switch result {
            case .success(let value):
                XCTAssert(value.count == 1)
            case .failure(_ ):
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
