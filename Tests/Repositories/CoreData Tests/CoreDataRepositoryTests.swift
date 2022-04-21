import XCTest
@testable import PelicanRepositories
import CoreData

final class CoreDataRepositoryTests: XCTestCase {
    
    private var sut: CoreDataRepository<TestModelEntity>!
    
    override func setUp() {
        let model = NSManagedObjectModel.mergedModel(from: [Bundle.module])
        let context: CoreDataContext = CoreDataContext(modelName: "TestModel", managedObjectModel: model)
        sut = CoreDataRepository<TestModelEntity>(entityName: "TestEntity", context: context.persistentContainer.viewContext)
    }
    
    func testIsEmpty() {
        XCTAssertTrue(sut.isEmpty)
    }
    
    func test_save_whenRecordNotExists_expectDataSaved() throws {
        let test = TestModelEntity(name: "name", age: 21)
        
        let result = try sut.add(element: test)
        let savedResult = sut.getAll[0]
        
        XCTAssertNotNil(savedResult)
        XCTAssertEqual(test, savedResult)
        XCTAssertEqual(test, result)
    }
    
    func test_save_whenRecordExists_expectErrorThrown() {
        let test = TestModelEntity(name: "name", age: 21)
        
        XCTAssertNoThrow(try sut.add(element: test))
        XCTAssertThrowsError(try sut.add(element: test))
    }
    
    func test_update_whenRecordDontExists_expectErrorThrown() {
        let test = TestModelEntity(name: "name", age: 21)
        
        XCTAssertThrowsError(try sut.update(element: test))
    }
    
    func test_update_whenRecordExists_expectRecordUpdated() throws {
        let test = TestModelEntity(name: "name", age: 21)
        let savedResult = try sut.add(element: test)
        let updatedRecord = TestModelEntity(name: "name", age: 24)
        
        let resultTransaction = try sut.update(element: updatedRecord)
        let result = sut.getAll[0]
        
        XCTAssertEqual(24, result.age)
        XCTAssertNotEqual(savedResult.age, resultTransaction.age)
    }
    
    func test_delete_whenRecordNotExists_expectNoResult() {
        let test = TestModelEntity(name: "name", age: 21)
        sut.delete(element: test)
        let result = sut.isEmpty
        
        XCTAssertTrue(result)
    }
    
    func test_delete_whenRecordExists_expectRecordDeleted() throws {
        let test = TestModelEntity(name: "name", age: 21)
        _ = try sut.add(element: test)
        
        let recordSaved = sut.getAll[0]
        sut.delete(element: test)
        let result = sut.isEmpty
        
        XCTAssertEqual(test, recordSaved)
        XCTAssertTrue(result)
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
        let test = TestModelEntity(name: "record1", age: 1)
        
        let result = sut.contains(element: test)
        
        XCTAssertFalse(result)
    }
    
    func test_contains_whenValueExists_expectTrue() throws {
        try loadRecords()
        let test = TestModelEntity(name: "record1", age: 1)
        
        let result = sut.contains(element: test)
        
        XCTAssertTrue(result)
    }
    
    func test_empty_whenRecords_expectTableToBeEmptied() throws {
        try loadRecords()
        
        let recordsLoaded = sut.isEmpty
        try sut.deleteAll()
        let result = sut.isEmpty
        
        XCTAssertFalse(recordsLoaded)
        XCTAssertTrue(result)
    }
    
    private func loadRecords() throws {
        let record1 = TestModelEntity(name: "record1", age: 1)
        let record2 = TestModelEntity(name: "record2", age: 12)
        let record3 = TestModelEntity(name: "record3", age: 14)
        let record4 = TestModelEntity(name: "record4", age: 17)
        _ = try sut.add(element: record1)
        _ = try sut.add(element: record2)
        _ = try sut.add(element: record3)
        _ = try sut.add(element: record4)
    }
    
}
