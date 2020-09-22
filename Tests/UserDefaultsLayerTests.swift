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
        XCTAssertNil(intPersistence.first)
        XCTAssert(intPersistence.isEmpty)
        XCTAssert(intPersistence.save(object: value))
        XCTAssert(!intPersistence.isEmpty)
        XCTAssertEqual(1,intPersistence.first)
    }
    
    func testRemoveOne() {
        let value = 1
        XCTAssert(intPersistence.isEmpty)
        XCTAssert(intPersistence.save(object: value))
        XCTAssert(!intPersistence.isEmpty)
        XCTAssertEqual(1,intPersistence.first)
        XCTAssert(intPersistence.delete(object: 1))
        XCTAssert(intPersistence.isEmpty)
    }
    
    func testSaveError() {
        let person = Person(name: "", age: Double.infinity)
        XCTAssertFalse(personPersistence.save(object: person))
    }
    
    func testFilterEmptyResult() {
        let person = Person(name: "", age: 23)
        XCTAssertTrue(personPersistence.save(object: person))
        XCTAssertNotNil(personPersistence.first)
        XCTAssertFalse(personPersistence.isEmpty)
        XCTAssertTrue(personPersistence.filter { $0.age < 21 }.isEmpty)
    }
    
    func testFilterResult() {
        let person = Person(name: "", age: 23)
        XCTAssertTrue(personPersistence.save(object: person))
        XCTAssertNotNil(personPersistence.first)
        XCTAssertFalse(personPersistence.isEmpty)
        XCTAssertFalse(personPersistence.filter { $0.age < 30 }.isEmpty)
    }
    
    func testUpdate() {
        let person = Person(name: "da person", age: 21)
        XCTAssertTrue(personPersistence.save(object: person))
        XCTAssertNotNil(personPersistence.first)
        XCTAssertEqual(personPersistence.first?.name, "da person")
        let personUpdated = Person(name: "updated", age: 21)
        XCTAssertTrue(personPersistence.update(object: personUpdated))
        XCTAssertEqual(personPersistence.first?.name, "updated")
    }
    
    func testUpdateFailure() {
        let person = Person(name: "da person", age: 21)
        XCTAssertTrue(personPersistence.save(object: person))
        XCTAssertNotNil(personPersistence.first)
        XCTAssertEqual(personPersistence.first?.name, "da person")
        let personUpdated = Person(name: "updated", age: Double.infinity)
        XCTAssertFalse(personPersistence.update(object: personUpdated))
    }
    
}

private struct Person: Codable {
    var name: String
    var age: Double
}
