//
//  KeychainLayerTests.swift
//  PelicanTests
//
//  Created by Daniel Koster on 1/21/20.
//  Copyright © 2020 Daniel Koster. All rights reserved.
//

import XCTest
import Pelican

class KeyValueRepositoryTests: XCTestCase {
    
    private var sut: KeyValueRepository<MockEntity>!
    private let mockStore = MockStore()
    
    override func setUp() {
        sut = KeyValueRepository<MockEntity>(key: "test",
                                             store: mockStore,
                                             jsonEncoder: JSONEncoder(),
                                             jsonDecoder: JSONDecoder())
    }
    
    func test_save_whenEncodingFails_expectErrorThrown() {
        let testEntity = MockEntity(parameter: "param", number: Double.infinity)
        
        XCTAssertThrowsError(try sut.save(element: testEntity))
    }
    
    func test_isEmpty() {
        XCTAssertTrue(sut.isEmpty)
    }
    
    func test_save_whenDataIsSaved_expectRetured() throws {
        let testEntity = MockEntity(parameter: "param", number: 12)
        
        let result = try sut.save(element: testEntity)
        
        XCTAssertEqual(testEntity, result)
    }
    
    func test_update_whenEncodingFails_expectErrorThrown() {
        let testEntity = MockEntity(parameter: "param", number: Double.infinity)
        
        XCTAssertThrowsError(try sut.update(element: testEntity))
    }
    
    func test_getAll() throws {
        mockStore.data = try JSONEncoder().encode(MockEntity(parameter: "param", number: 12))
        
        let result = sut.getAll
        
        XCTAssertEqual([MockEntity(parameter: "param", number: 12)], result)
    }
    
    func test_getAll_whenArray_expectCorrectResult() throws {
        mockStore.data = try JSONEncoder().encode([MockEntity(parameter: "param", number: 12)])
        
        let result = sut.getAll
        
        XCTAssertEqual([MockEntity(parameter: "param", number: 12)], result)
    }
    
    func test_getAll_whenNoValuesInStore_expectEmptyResult() throws {
        let result = sut.getAll
        
        XCTAssertEqual([], result)
    }
    
    func test_getAll_whenCorruptedData_expectEmptyResult() throws {
        mockStore.data = Data()
        
        let result = sut.getAll
        
        XCTAssertEqual([], result)
    }
    
    func test_delete() {
        sut.delete(element: MockEntity(parameter: "12", number: 1))
        
        XCTAssertTrue(mockStore.didDelete)
    }
    
    func test_contains_whenNoValue_expectFalse() {
        let result = sut.contains(element: MockEntity(parameter: "param", number: 2))
        
        XCTAssertFalse(result)
    }
    
    func test_contains_whenValue_expectTrue() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode(value)
        let result = sut.contains(element: MockEntity(parameter: "param", number: 2))
        
        XCTAssertTrue(result)
    }
    
    func test_contains_whenValueInArray_expectTrue() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode([value])
        let result = sut.contains(element: MockEntity(parameter: "param", number: 2))
        
        XCTAssertTrue(result)
    }
    
    func test_contains_whenCorruptedData_expectFalse() throws {
        mockStore.data = try JSONEncoder().encode([1])
        let result = sut.contains(element: MockEntity(parameter: "param", number: 2))
        
        XCTAssertFalse(result)
    }
    
    func test_empty() {
        sut.empty()
        
        XCTAssertTrue(mockStore.didDelete)
    }
    
    func test_containsWithCondition_whenNoValue_expectFalse() {
        let result = sut.contains { $0.parameter == "param" }
        
        XCTAssertFalse(result)
    }
    
    func test_containsWithCondition_whenValue_expectTrue() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode(value)
        let result = sut.contains { $0.parameter == "param" }
        
        XCTAssertTrue(result)
    }
    
    func test_containsWithCondition_whenValueInArray_expectTrue() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode([value])
        let result = sut.contains { $0.parameter == "param" }
        
        XCTAssertTrue(result)
    }
    
    func test_containsWithCondition_whenCorruptedData_expectFalse() throws {
        mockStore.data = try JSONEncoder().encode([1])
        let result = sut.contains { $0.parameter == "param" }
        
        XCTAssertFalse(result)
    }
    
    func test_first_whenValue_expectNotNil() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode(value)
        let result = sut.first
        
        XCTAssertEqual(value, result)
    }
    
    func test_first_whenArrayValue_expectNotNil() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode([value])
        let result = sut.first
        
        XCTAssertEqual(value, result)
    }
    
    func test_first_whenValue_expectNNil() throws {
        let result = sut.first
        
        XCTAssertNil(result)
    }
    
    func test_first_whenCorruptedData_expectNNil() throws {
        mockStore.data = Data()
        let result = sut.first
        
        XCTAssertNil(result)
    }
    
    func test_firstWithCondition_whenValue_expectNotNil() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode(value)
        let result = sut.first { $0.parameter == "param" }
        
        XCTAssertEqual(value, result)
    }
    
    func test_firstWithCondition_whenValueNotMatchesCondition_expectNil() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode(value)
        let result = sut.first { $0.parameter == "param1" }
        
        XCTAssertNil(result)
    }
    
    func test_firstWithCondition_whenArrayValue_expectNotNil() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode([value])
        let result = sut.first { $0.parameter == "param" }
        
        XCTAssertEqual(value, result)
    }
    
    func test_firstWithCondition_whenValue_expectNNil() throws {
        let result = sut.first { $0.parameter == "param" }
        
        XCTAssertNil(result)
    }
    
    func test_firstWithCondition_whenCorruptedData_expectNNil() throws {
        mockStore.data = Data()
        let result = sut.first { $0.parameter == "param" }
        
        XCTAssertNil(result)
    }
    
    func test_filter_whenValue_expectNotNil() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode(value)
        let result = sut.filter { $0.parameter == "param" }
        
        XCTAssertEqual([value], result)
    }
    
    func test_filter_whenValueNotMatchesCondition_expectNil() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode(value)
        let result = sut.filter { $0.parameter == "param1" }
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_filter_whenArrayValue_expectNotNil() throws {
        let value = MockEntity(parameter: "param", number: 2)
        mockStore.data = try JSONEncoder().encode([value])
        let result = sut.filter { $0.parameter == "param" }
        
        XCTAssertEqual([value], result)
    }
    
    func test_filter_whenValue_expectNNil() throws {
        let result = sut.filter { $0.parameter == "param" }
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_filter_whenCorruptedData_expectNNil() throws {
        mockStore.data = Data()
        let result = sut.filter { $0.parameter == "param" }
        
        XCTAssertTrue(result.isEmpty)
    }
}
