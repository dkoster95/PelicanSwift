import XCTest
import PelicanKeychain
import PelicanProtocols

class KeychainStoreTests: XCTestCase {
    
    private var sut = KeychainStore(service: "",
                                    groupId: nil,
                                    accesibility: .afterFirstUnlock,
                                    securityClass: .genericPassword,
                                    logger: Log())

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    func test_save_whenDataNotExists_expectDataSaved() throws {
        let value = 2
        let encodedValue = try jsonEncoder.encode(value)
        
        let result = sut.save(data: encodedValue, key: "test")
        
        XCTAssertTrue(result)
        XCTAssertTrue(sut.delete(key: "test"))
    }
    
    func test_subscriptSave_whenNoValue_expectValueCreated() throws {
        let value = 2
        let encodedValue = try jsonEncoder.encode(value)
        
        sut["test"] = encodedValue
        let result = sut["test"]
        
        XCTAssertNotNil(result)
    }
    
    func test_subscriptSave_whenSettingNil_expectValueRemoved() throws {
        let value = 2
        let encodedValue = try jsonEncoder.encode(value)
        
        sut["test"] = encodedValue
        let result = sut["test"]
        sut["test"] = nil
        let deletedResult = sut["test"]
        
        XCTAssertNotNil(result)
        XCTAssertNil(deletedResult)
    }
    
    func test_save_whenDataExists_expectDataUpdated() throws {
        let value = 2
        let encodedValue = try jsonEncoder.encode(value)
        let encodedNewValue = try jsonEncoder.encode(3)
        
        _ = sut.save(data: encodedValue, key: "test")
        let result = sut.save(data: encodedNewValue, key: "test")
        let fetchResult = try jsonDecoder.decode(Int.self, from: sut.fetch(key: "test") ?? Data())
        
        XCTAssertTrue(result)
        XCTAssertEqual(3, fetchResult)
        XCTAssertTrue(sut.delete(key: "test"))
    }
    
    func test_delete_whenDataExists_expectDataDeleted() throws {
        let value = 2
        let encodedValue = try jsonEncoder.encode(value)
        
        _ = sut.save(data: encodedValue, key: "test")
        let result = sut.delete(key: "test")
        
        XCTAssertTrue(result)
        XCTAssertNil(sut.fetch(key: "test"))
    }
    
    func test_delete_whenDataNotExists_expectDataNotDeleted() throws {        
        let result = sut.delete(key: "test")
        
        XCTAssertFalse(result)
    }
    
    func test_update_whenValueNotExists_expectDataNotSavedSaved() throws {
        let value = 2
        let encodedValue = try jsonEncoder.encode(value)
        
        let result = sut.update(data: encodedValue, key: "test")
        
        XCTAssertFalse(result)
    }
    
    func test_update_whenDataExists_expectDataUpdated() throws {
        let value = 2
        let encodedValue = try jsonEncoder.encode(value)
        let encodedNewValue = try jsonEncoder.encode(3)
        
        _ = sut.save(data: encodedValue, key: "test")
        let result = sut.update(data: encodedNewValue, key: "test")
        let fetchResult = try jsonDecoder.decode(Int.self, from: sut.fetch(key: "test") ?? Data())
        
        XCTAssertTrue(result)
        XCTAssertEqual(3, fetchResult)
        XCTAssertTrue(sut.delete(key: "test"))
    }

}

struct Log: Logger {
    public init() {}
    public func debug(_ msg: String) {
        #if DEBUG
        NSLog("Persistence: \(thread) ✅ DEBUG -- \(msg)")
        #endif
    }

    public func error(_ msg: String) {
        #if DEBUG
            NSLog("Persistence: \(thread) ❌ ERROR -- \(msg)")
        #endif
    }
    
    public func info(_ msg: String) {
        #if DEBUG
            NSLog("Persistence: \(thread) ℹ️ INFO -- \(msg)")
        #endif
    }
    
    private var thread: String {
        var thread = "Thread:"
        if Thread.current.isMainThread {
            thread += "main:"
        } else {
            thread += "background:"
        }
        thread += "priority:\(Thread.current.threadPriority)"
        return thread
    }
}
