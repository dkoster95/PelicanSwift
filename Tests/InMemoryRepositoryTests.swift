//
//  InMemoryRepositoryTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 9/22/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import XCTest
import Pelican
class InMemoryRepositoryTests: XCTestCase {
    var subject = InMemoryRepository<Int>()
    override func setUp() {
        subject.empty()
    }

    func testSave() {
        XCTAssertTrue(subject.save(object: 2))
        XCTAssertEqual(subject.first, 2)
        XCTAssertFalse(subject.isEmpty)
    }
    
    func testDelete() {
        XCTAssertTrue(subject.save(object: 2))
        XCTAssertEqual(subject.first, 2)
        XCTAssertFalse(subject.isEmpty)
        XCTAssertTrue(subject.delete(object: 2))
        XCTAssertTrue(subject.isEmpty)
    }
    
    func testUpdate() {
        XCTAssertTrue(subject.save(object: 2))
        XCTAssertEqual(subject.first, 2)
        XCTAssertFalse(subject.isEmpty)
        XCTAssertTrue(subject.update(object: 2))
        XCTAssertFalse(subject.isEmpty)
    }
    
    func testFetch() {
        XCTAssertTrue(subject.save(object: 2))
        XCTAssertEqual(subject.fetchAll, [2])
    }
}
