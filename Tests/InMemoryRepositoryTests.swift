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

    func test_save() throws {
        XCTAssertEqual(2, try subject.save(element: 2))
        XCTAssertEqual(subject.first, 2)
        XCTAssertFalse(subject.isEmpty)
    }
    
    func test_getAll() throws {
        XCTAssertEqual(2, try subject.save(element: 2))
        XCTAssertEqual(subject.getAll[0], 2)
        XCTAssertFalse(subject.isEmpty)
    }
    
    func test_delete() throws {
        XCTAssertEqual(2, try subject.save(element: 2))
        XCTAssertEqual(subject.first, 2)
        XCTAssertFalse(subject.isEmpty)
        subject.delete(element: 2)
        XCTAssertTrue(subject.isEmpty)
    }
    
    func test_update() throws {
        XCTAssertEqual(2, try subject.save(element: 2))
        XCTAssertEqual(subject.first, 2)
        XCTAssertFalse(subject.isEmpty)
        XCTAssertEqual(3, try subject.update(element: 3))
    }
    
}
