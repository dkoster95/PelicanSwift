//
//  UserDefaultsLayerTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 1/21/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import XCTest
import Pelican

class UserDefaultsLayerTests: XCTestCase {
    
    private let intPersistence = UserDefaultsRepository<Int>(key: "test", userDefaultsSession: .standard)
    private let personPersistence = UserDefaultsRepository<Person>(key: "test2", userDefaultsSession: .standard)
    
    private func emptyPersistence() {
        intPersistence.empty()
        personPersistence.empty()
    }
    
    override func setUp() {
        emptyPersistence()
    }
    
    func testAddOne() {
        let value = 1
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
                XCTAssert(true)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssert(intPersistence.fetchAll.isEmpty)
        XCTAssert(intPersistence.save(object: value))
        XCTAssert(!intPersistence.fetchAll.isEmpty)
        XCTAssert(intPersistence.fetchAll[0] == 1)
    }
    
    func testRemoveOne() {
        let value = 1
        XCTAssert(intPersistence.fetchAll.isEmpty)
        XCTAssert(intPersistence.save(object: value))
        XCTAssert(!intPersistence.fetchAll.isEmpty)
        XCTAssert(intPersistence.fetchAll[0] == 1)
        XCTAssert(intPersistence.delete(object: 1))
        XCTAssert(intPersistence.fetchAll.isEmpty)
    }
    
    func testRetrieve() {
        let value = 1
        XCTAssert(intPersistence.fetchAll.isEmpty)
        XCTAssert(intPersistence.save(object: value))
        XCTAssert(!intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieveFirst(query: nil) {
            result in
            switch result {
            case .success(let int):
                XCTAssertEqual(int,value)
            case .failure(_ ):
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    func testRetrieveWithQueryError() {
        let value = 1
        XCTAssert(intPersistence.fetchAll.isEmpty)
        XCTAssert(intPersistence.save(object: value))
        XCTAssert(!intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieveFirst(query: { $0 == 2}) {
            result in
            switch result {
            case .success(_ ):
                XCTAssert(false)
            case .failure(_ ):
                XCTAssert(true)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieveWithQuery() {
        let value = 1
        XCTAssert(intPersistence.fetchAll.isEmpty)
        XCTAssert(intPersistence.save(object: value))
        XCTAssert(!intPersistence.fetchAll.isEmpty)
        let expectation = XCTestExpectation()
        intPersistence.retrieveFirst(query: { $0 == 1}) {
            result in
            switch result {
            case .success(let int):
                XCTAssertEqual(int, value)
            case .failure(_ ):
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSaveError() {
        let person = Person(name: "", age: Double.infinity)
        XCTAssertFalse(personPersistence.save(object: person))
    }

}

private struct Person: Codable {
    var name: String
    var age: Double
}

