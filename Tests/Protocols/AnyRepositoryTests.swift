import XCTest
import PelicanProtocols

class AnyRepositoryTests: XCTestCase {

    private let mockRepository = MockRepository<Int>()
    private var sut: AnyRepository<Int>!
    
    override func setUp() {
        sut = mockRepository.eraseToAnyRepository()
    }
    
    func test_add() throws {
        let result = try sut.add(element: 1)
        
        XCTAssertTrue(mockRepository.addCalled)
        XCTAssertEqual(1, result)
    }
    
    func test_update() throws {
        let result = try sut.update(element: 1)
        
        XCTAssertTrue(mockRepository.updateCalled)
        XCTAssertEqual(1, result)
    }
    
    func test_delete() throws {
        try sut.delete(element: 1)
        
        XCTAssertTrue(mockRepository.deleteCalled)
    }
    
    func test_all() throws {
        mockRepository.getAllValue = [1]
        let result = sut.getAll
        
        XCTAssertTrue(mockRepository.getAllCalled)
        XCTAssertEqual([1], result)
    }
    
    func test_filter() throws {
        mockRepository.filterResult = [1, 2, 3]
        let result = sut.filter { _ in true }
        
        XCTAssertEqual([1, 2, 3], result)
        XCTAssertTrue(mockRepository.didFilter)
    }
    
    func test_firstWithCondition() throws {
        mockRepository.firstResult = 1
        
        let result = sut.first { _ in return true }
        
        XCTAssertEqual(1, result)
        XCTAssertTrue(mockRepository.firstCalled)
    }
    
    func test_containsWithCondition() throws {
        mockRepository.containsWithConditionResult = true
        let result = sut.contains { _ in return true }
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockRepository.containsWithConditionCalled)
    }
    
    func test_contains() throws {
        mockRepository.containsResult = false
        let result = sut.contains(element: 5)
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockRepository.containsCalled)
    }
    
    func test_isEmpty_whenNoValues_expectTrue() {
        mockRepository.isEmptyValue = false
        let result = sut.isEmpty
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockRepository.isEmptyCalled)
    }
    
    func test_deleteAll_whenCalled_expectRealRepositoryToDeleteAll() throws {
        try sut.deleteAll()
        
        XCTAssertTrue(mockRepository.deleteAllCalled)
    }

}

private class MockRepository<Element: Equatable>: Repository {
    init() {}
    var addCalled = false
    func add(element: Element) throws -> Element {
        addCalled = true
        return element
    }
    
    var updateCalled = false
    func update(element: Element) throws -> Element {
        updateCalled = true
        return element
    }
    
    var deleteCalled = false
    func delete(element: Element) {
        deleteCalled = true
    }
    
    var didFilter = false
    var filterResult: [Element] = []
    func filter(query: (Element) -> Bool) -> [Element] {
        didFilter = true
        return filterResult
    }
    
    var firstCalled = false
    var firstResult: Element? = nil
    func first(where: (Element) -> Bool) -> Element? {
        firstCalled = true
        return firstResult
    }
    
    var containsWithConditionCalled = false
    var containsWithConditionResult = false
    func contains(condition: (Element) -> Bool) -> Bool {
        containsWithConditionCalled = true
        return containsWithConditionResult
    }
    
    var containsCalled = false
    var containsResult = false
    func contains(element: Element) -> Bool {
        containsCalled = true
        return containsResult
    }
    
    var isEmptyCalled = false
    var isEmptyValue = false
    var isEmpty: Bool {
        isEmptyCalled = true
        return isEmptyValue
    }
    
    var getAllCalled = false
    var getAllValue: [Element] = []
    var getAll: [Element] {
        getAllCalled = true
        return getAllValue
    }
    
    var deleteAllCalled = false
    func deleteAll() throws {
        deleteAllCalled = true
    }
    
    
}
