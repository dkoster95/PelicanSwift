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

    private var subject: CoreDataRepository<TestEntity>!
    
    private var context: CoreDataContext = CoreDataContext(modelName: "TestModel")
    
    override func setUp() {
        subject = CoreDataRepository<TestEntity>(entityName: "TestEntity", context: context)
        subject.empty()
    }
    
    func testIsEmpty() {
        XCTAssertTrue(subject.isEmpty)
    }
    
    func testSave() {
        let test = TestEntity(name: "savetest", age: 23, context: context.persistentContainer.viewContext)
        XCTAssertTrue(subject.save(object: test))
    }
    
    func testErrorContext() {
        let test = TestEntity(name: "savetest", age: 23, context: CoreDataContext(modelName: "TestModel").persistentContainer.viewContext)
        XCTAssertFalse(subject.save(object: test))
        XCTAssertFalse(subject.delete(object: test))
        test.age = 25
        XCTAssertFalse(subject.update(object: test))
    }
    
    func testDelete() {
        let test = TestEntity(name: "savetest", age: 23, context: context.persistentContainer.viewContext)
        XCTAssertTrue(subject.save(object: test))
        XCTAssertTrue(subject.delete(object: test))
        XCTAssertTrue(subject.isEmpty)
    }
    private func load() {
        _ = TestEntity(name: "savetest", age: 23, context: context.persistentContainer.viewContext)
        _ = TestEntity(name: "savetest2", age: 24, context: context.persistentContainer.viewContext)
        _ = TestEntity(name: "savetest3", age: 25, context: context.persistentContainer.viewContext)
        _ = subject.save()
    }
    
    func testFetchAll() {
        load()
        XCTAssertFalse(subject.isEmpty)
        XCTAssertTrue(subject.fetchAll.count == 3)
    }
    
    func testFilter() {
        load()
        XCTAssertFalse(subject.isEmpty)
        XCTAssertTrue(subject.fetchAll.count == 3)
        let result = subject.filter { $0.age >= 25 }
        XCTAssertEqual(result[0].name, "savetest3")
    }
    
    func testUpdate() {
        let test = TestEntity(name: "savetest", age: 23, context: context.persistentContainer.viewContext)
        XCTAssertTrue(subject.save(object: test))
        XCTAssertEqual(subject.first?.age, 23)
        test.age = 32
        XCTAssertTrue(subject.update(object: test))
        XCTAssertEqual(subject.first?.age, 32)
    }

}
