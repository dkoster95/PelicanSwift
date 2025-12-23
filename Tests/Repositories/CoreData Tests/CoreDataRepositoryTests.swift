import XCTest
@testable import PelicanRepositories
import PelicanProtocols
import CoreData
import Combine

// swiftlint:disable file_length type_body_length
final class CoreDataRepositoryTests: XCTestCase {
    
    private var sut: CoreDataRepository<TestModelEntity>!
    private var disposeBag = Set<AnyCancellable>()
    
    override func setUp() {
        let model = NSManagedObjectModel.mergedModel(from: [Bundle.module])
        let cdContext: CoreDataContext = CoreDataContext(modelName: "TestModel", managedObjectModel: model)
        let context = CDContext(context: cdContext.persistentContainer.viewContext)
        sut = CoreDataRepository<TestModelEntity>(context: context)
    }
    
    func testIsEmpty() {
        XCTAssertTrue(sut.isEmpty)
    }
    
    func test_save_whenRecordNotExists_expectDataSaved() throws {
        let test = TestModelEntity(name: "name", age: 21)
        
        let result = try sut.add(element: test)
        let savedResult = sut.find()[0]
        
        XCTAssertNotNil(savedResult)
        XCTAssertEqual(test, savedResult)
        XCTAssertEqual(test, result)
    }
    
    func test_save_whenRecordExists_expectErrorThrown() {
        let test = TestModelEntity(name: "name", age: 21)
        
        XCTAssertNoThrow(try sut.add(element: test))
        XCTAssertThrowsError(try sut.add(element: test))
    }
    
    func test_saveAsync_whenRecordNotExists_expectDataSaved() async throws {
        let test = TestModelEntity(name: "name", age: 21)
        
        let result = try await sut.add(element: test)
        let savedResult = await sut.find()[0]
        
        XCTAssertNotNil(savedResult)
        XCTAssertEqual(test, savedResult)
        XCTAssertEqual(test, result)
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
        let result = sut.find()[0]
        
        XCTAssertEqual(24, result.age)
        XCTAssertNotEqual(savedResult.age, resultTransaction.age)
    }
    
    func test_updateAsync_whenRecordExists_expectRecordUpdated() async throws {
        let test = TestModelEntity(name: "name", age: 21)
        let savedResult = try await sut.add(element: test)
        let updatedRecord = TestModelEntity(name: "name", age: 24)
        
        let resultTransaction = try await sut.update(element: updatedRecord)
        let result = await sut.find()[0]
        
        XCTAssertEqual(24, result.age)
        XCTAssertNotEqual(savedResult.age, resultTransaction.age)
    }
    
    func test_delete_whenRecordNotExists_expectNoResult() throws {
        let test = TestModelEntity(name: "name", age: 21)
        try sut.delete(element: test)
        let result = sut.isEmpty
        
        XCTAssertTrue(result)
    }
    
    func test_delete_whenRecordExists_expectRecordDeleted() throws {
        let test = TestModelEntity(name: "name", age: 21)
        _ = try sut.add(element: test)
        
        let recordSaved = sut.find()[0]
        try sut.delete(element: test)
        let result = sut.isEmpty
        
        XCTAssertEqual(test, recordSaved)
        XCTAssertTrue(result)
    }
    
    func test_deleteAsync_whenRecordExists_expectRecordDeleted() async throws {
        let test = TestModelEntity(name: "name", age: 21)
        _ = try await sut.add(element: test)
        
        let recordSaved = await sut.find()[0]
        try await sut.delete(element: test)
        let result = sut.isEmpty
        
        XCTAssertEqual(test, recordSaved)
        XCTAssertTrue(result)
    }
    
    func test_find_whenNoRecords_expectEmpty() {
        let result = sut.find()
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_find_whenRecords_expectListOfRecords() throws {
        try loadRecords()
        let result = sut.find()
        
        XCTAssertEqual(4, result.count)
    }
    
    func test_findAsync_whenRecords_expectListOfRecords() async throws {
        try loadRecords()
        let result = await sut.find()
        
        XCTAssertEqual(4, result.count)
    }
    
    func test_findWithQuery_whenRecords_expectListOfRecordsFiltered() throws {
        try loadRecords()
        let result = sut.find { $0.age.truncatingRemainder(dividingBy: 2) == 0 }
        
        XCTAssertEqual(2, result.count)
    }
    
    func test_findWithQueryAsync_whenRecords_expectListOfRecordsFiltered() async throws {
        try loadRecords()
        let result = await sut.find { $0.age.truncatingRemainder(dividingBy: 2) == 0 }
        
        XCTAssertEqual(2, result.count)
    }
    
    func test_findWithQuery_whenNoRecords_expectEmptyResult() throws {
        try loadRecords()
        let result = sut.find { $0.age > 20 }
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_findWithPredicate_whenPredicateMatches_expectCorrectResults() throws {
        try loadRecords()
        
        let result = sut.find(predicate: NSPredicate(format: "age > %i", 12), limit: nil, sortDescriptor: nil)
        
        XCTAssertEqual(result.count, 2)
    }
    
    func test_findWithPredicateAsync_whenPredicateMatches_expectCorrectResults() async throws {
        try loadRecords()
        
        let result = await sut.find(predicate: NSPredicate(format: "age > %i", 12), limit: nil, sortDescriptor: nil)
        
        XCTAssertEqual(result.count, 2)
    }
    
    func test_findWithPredicate_whenPredicateMatchesSorted_expectCorrectResults() throws {
        try loadRecords()
        
        let result = sut.find(predicate: NSPredicate(format: "age > %i", 12), limit: 1, sortDescriptor: NSSortDescriptor(key: "name", ascending: false))
        
        XCTAssertEqual("record4", result[0].name)
        XCTAssertEqual(result.count, 1)
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
    
    func test_containsAsync_whenValueExists_expectTrue() async throws {
        try loadRecords()
        let test = TestModelEntity(name: "record1", age: 1)
        
        let result = await sut.contains(element: test)
        
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
    
    func test_emptyAsync_whenRecords_expectTableToBeEmptied() async throws {
        try loadRecords()
        
        let recordsLoaded = sut.isEmpty
        try await sut.deleteAll()
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
    
    private func loadRecordsBatch() throws {
        let record1 = TestModelEntity(name: "record1", age: 1)
        let record2 = TestModelEntity(name: "record2", age: 12)
        let record3 = TestModelEntity(name: "record3", age: 14)
        let record4 = TestModelEntity(name: "record4", age: 17)
        try sut.add(elements: [record1, record2, record3, record4])
        
    }
    
}
