//
//  AnyRepositoryTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 2/28/22.
//  Copyright © 2022 Daniel Koster. All rights reserved.
//

import XCTest
import Pelican

class AnyRepositoryTests: XCTestCase {

    private let inMemoryRepository = InMemoryRepository<Int>()
    private var sut: AnyRepository<Int>!
    
    override func setUp() {
        sut = inMemoryRepository.eraseToAnyRepository()
    }
    
    func test_save() throws {
        let result = try sut.save(element: 1)
        let fetchedResult = sut.first
        
        XCTAssertEqual(1, result)
        XCTAssertEqual(1, fetchedResult)
    }
    
    func test_update() throws {
        let result = try sut.update(element: 1)
        let fetchedResult = sut.first
        
        XCTAssertEqual(1, result)
        XCTAssertEqual(1, fetchedResult)
    }
    
    func test_delete() throws {
        _ = try sut.save(element: 1)
        let fetchedResult = sut.first
        sut.delete(element: 1)
        let fetchedResultAfterDeletion = sut.first
        
        XCTAssertEqual(1, fetchedResult)
        XCTAssertNil(fetchedResultAfterDeletion)
    }
    
    func test_all() throws {
        _ = try sut.save(element: 1)
        let result = sut.getAll
        
        XCTAssertEqual(1, result.count)
    }
    
    func test_filter() throws {
        _ = try sut.save(element: 1)
        _ = try sut.save(element: 2)
        _ = try sut.save(element: 3)
        _ = try sut.save(element: 4)
        
        let result = sut.filter { $0 % 2 != 0 }
        
        XCTAssertEqual(2, result.count)
        XCTAssertEqual([1,3], result)
    }
    
    func test_firstWithCondition() throws {
        _ = try sut.save(element: 1)
        _ = try sut.save(element: 2)
        _ = try sut.save(element: 3)
        _ = try sut.save(element: 4)
        
        let result = sut.first { $0 % 4 == 0 }
        
        XCTAssertNotNil(result)
    }
    
    func test_first() throws {
        _ = try sut.save(element: 1)
        _ = try sut.save(element: 2)
        _ = try sut.save(element: 3)
        _ = try sut.save(element: 4)
        
        let result = sut.first
        
        XCTAssertEqual(1, result)
    }
    
    func test_containsWithCondition() throws {
        _ = try sut.save(element: 1)
        _ = try sut.save(element: 2)
        _ = try sut.save(element: 3)
        _ = try sut.save(element: 4)
        
        let result = sut.contains { $0 % 4 == 0 }
        
        XCTAssertTrue(result)
    }
    
    func test_contains() throws {
        _ = try sut.save(element: 1)
        _ = try sut.save(element: 2)
        _ = try sut.save(element: 3)
        _ = try sut.save(element: 4)
        
        let result = sut.contains(element: 5)
        
        XCTAssertFalse(result)
    }
    
    func test_isEmpty_whenNoValues_expectTrue() {
        let result = sut.isEmpty
        
        XCTAssertTrue(result)
    }
    
    func test_isEmpty_whenValues_expectFalse() throws {
        _ = try sut.save(element: 1)
        let result = sut.isEmpty
        
        XCTAssertFalse(result)
    }
    
    func test_empty() throws {
        _ = try sut.save(element: 1)
        sut.empty()
        
        XCTAssertTrue(sut.isEmpty)
    }

}
