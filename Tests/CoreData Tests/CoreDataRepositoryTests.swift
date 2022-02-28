//
//  CoreDataRepositoryTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 1/21/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import XCTest
@testable import Pelican
@testable import TestApp
import CoreData

class CoreDataRepositoryTests: XCTestCase {
    
    private var context: CoreDataContext = CoreDataContext(modelName: "TestModel")
    
    private var sut: CoreDataRepository<TestEntity>!
    
    override func setUp() {
        sut = CoreDataRepository<TestEntity>(entityName: "TestEntity", context: context.persistentContainer.viewContext)
    }
    
    func testIsEmpty() {
        XCTAssertTrue(sut.isEmpty)
    }
    
    func test_save_whenRecordNotExists_expectDataSaved() throws {
        let test = TestEntity(name: "name", age: 21)
        
        let result = try sut.save(element: test)
        let savedResult = sut.first
        
        XCTAssertNotNil(savedResult)
        XCTAssertEqual(test, savedResult)
        XCTAssertEqual(test, result)
    }
    
    func test_save_whenRecordExists_expectErrorThrown() {
        let test = TestEntity(name: "name", age: 21)
        
        XCTAssertNoThrow(try sut.save(element: test))
        XCTAssertThrowsError(try sut.save(element: test))
    }
    
    func test_update_whenRecordDontExists_expectErrorThrown() {
        let test = TestEntity(name: "name", age: 21)
        
        XCTAssertThrowsError(try sut.update(element: test))
    }
    
    func test_update_whenRecordExists_expectRecordUpdated() throws {
        let test = TestEntity(name: "name", age: 21)
        let savedResult = try sut.save(element: test)
        let updatedRecord = TestEntity(name: "name", age: 24)
        
        let resultTransaction = try sut.update(element: updatedRecord)
        let result = sut.first
        
        XCTAssertEqual(24, result?.age)
        XCTAssertNotEqual(savedResult.age, resultTransaction.age)
    }
    
    func test_delete_whenRecordNotExists_expectNoResult() {
        let test = TestEntity(name: "name", age: 21)
        sut.delete(element: test)
        let result = sut.first
        
        XCTAssertNil(result)
    }
    
    func test_delete_whenRecordExists_expectRecordDeleted() throws {
        let test = TestEntity(name: "name", age: 21)
        _ = try sut.save(element: test)
        
        let recordSaved = sut.first
        sut.delete(element: test)
        let result = sut.first
        
        XCTAssertEqual(test, recordSaved)
        XCTAssertNil(result)
    }
    
    func test_getAll_whenNoRecords_expectEmpty() {
        let result = sut.getAll
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_getAll_whenRecords_expectListOfRecords() throws {
        try loadRecords()
        let result = sut.getAll
        
        XCTAssertEqual(4, result.count)
    }
    
    func test_filter_whenRecords_expectListOfRecordsFiltered() throws {
        try loadRecords()
        let result = sut.filter { $0.age.truncatingRemainder(dividingBy: 2) == 0 }
        
        XCTAssertEqual(2, result.count)
    }
    
    func test_filter_whenNoRecords_expectEmptyResult() throws {
        try loadRecords()
        let result = sut.filter { $0.age > 20 }
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_first_whenRecordsMatchCondition_expectFirstResult() throws {
        try loadRecords()
        let result = sut.first { $0.age < 14 }
        
        XCTAssertEqual(12, result?.age)
    }
    
    func test_first_whenNoRecordsMatchCondition_expectNil() throws {
        try loadRecords()
        let result = sut.first { $0.age > 24 }
        
        XCTAssertNil(result)
    }
    
    func test_isEmpty_whenNoRecords_expectEmpty() {
        XCTAssertTrue(sut.isEmpty)
    }
    
    func test_isEmpty_whenRecords_expectEmptyFalse() throws {
        try loadRecords()
        XCTAssertFalse(sut.isEmpty)
    }
    
    func test_contains_whenNoValueExists_expectFalse() {
        let test = TestEntity(name: "record1", age: 1)
        
        let result = sut.contains(element: test)
        
        XCTAssertFalse(result)
    }
    
    func test_contains_whenValueExists_expectTrue() throws {
        try loadRecords()
        let test = TestEntity(name: "record1", age: 1)
        
        let result = sut.contains(element: test)
        
        XCTAssertTrue(result)
    }
    
    func test_empty_whenRecords_expectTableToBeEmptied() throws {
        try loadRecords()
        
        let recordsLoaded = sut.isEmpty
        sut.empty()
        let result = sut.isEmpty
        
        XCTAssertFalse(recordsLoaded)
        XCTAssertTrue(result)
    }
    
    private func loadRecords() throws {
        let record1 = TestEntity(name: "record1", age: 1)
        let record2 = TestEntity(name: "record2", age: 12)
        let record3 = TestEntity(name: "record3", age: 14)
        let record4 = TestEntity(name: "record4", age: 17)
        _ = try sut.save(element: record1)
        _ = try sut.save(element: record2)
        _ = try sut.save(element: record3)
        _ = try sut.save(element: record4)
    }
    
}
