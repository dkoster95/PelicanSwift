import XCTest
import PelicanRepositories

final class ObjectKeyValueStoreTests: XCTestCase {
    private let mockStore = MockStore()
    private var sut: ObjectKeyValueStore!
    
    override func setUp() {
        sut = ObjectKeyValueStore(encoder: JSONEncoder(), decoder: JSONDecoder(), store: mockStore)
    }
    
    private func makeStore(withEncoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder(), andStore: MockStore = MockStore()) -> ObjectKeyValueStore {
        return ObjectKeyValueStore(encoder: withEncoder, decoder: decoder, store: andStore)
    }
    
    func test_save_whenObjectIsEncodable_expectTrue() throws {
        let element = MockEntity(parameter: "someParam", number: 1)
        
        let result = try sut.save(element: element, key: "element1")
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockStore.didSave)
    }
    
    func test_save_whenEncodingFails_expectErrorThrown() {
        let sut = makeStore(withEncoder: FakeJSONEncoder())
        let element = MockEntity(parameter: "someParam", number: 1)
        
        XCTAssertThrowsError(try sut.save(element: element, key: "element1"))
    }
    
    func test_update_whenObjectIsEncodable_expectTrue() throws {
        let element = MockEntity(parameter: "someParam", number: 1)
        
        let result = try sut.update(element: element, key: "element1")
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockStore.didUpdate)
    }
    
    func test_update_whenEncodingFails_expectErrorThrown() {
        let sut = makeStore(withEncoder: FakeJSONEncoder())
        let element = MockEntity(parameter: "someParam", number: 1)
        
        XCTAssertThrowsError(try sut.update(element: element, key: "element1"))
    }
    
    func test_delete_expectStoreToBeCalled() {
        _ = sut.delete(key: "someParam")
        
        XCTAssertTrue(mockStore.didDelete)
    }
    
    func test_fetch_whenNoValueFound_expectNil() throws {
        mockStore.data = nil
        
        let result = try sut.fetch(key: "key", type: MockEntity.self)
        
        XCTAssertNil(result)
    }
    
    func test_fetch_whenDecoderFails_expectError() throws {
        mockStore.data = Data()
        
        XCTAssertThrowsError(try sut.fetch(key: "key", type: MockEntity.self))
    }
    
    func test_fetch_whenDataFound_expectCorrectData() throws {
        mockStore.data = try JSONEncoder().encode(MockEntity(parameter: "param", number: 1))
        
        let result = try sut.fetch(key: "key", type: MockEntity.self)
        
        XCTAssertEqual(MockEntity(parameter: "param", number: 1), result)
    }
}
