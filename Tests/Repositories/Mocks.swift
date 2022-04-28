import Foundation
import PelicanProtocols

struct MockEntity: Codable, Equatable {
    let parameter: String
    let number: Double
}
func == (lhs: MockEntity, rhs: MockEntity) -> Bool {
    return lhs.parameter == rhs.parameter && lhs.number == rhs.number
}

class MockStore: KeyValueStore {
    
    var didSave = false
    func save(data: Data, key: String) -> Bool {
        didSave = true
        return didSave
    }
    var didUpdate = false
    func update(data: Data, key: String) -> Bool {
        didUpdate = true
        return didUpdate
    }
    
    var didDelete = false
    func delete(key: String) -> Bool {
        didDelete = true
        return didDelete
    }
    
    var didFetch = false
    var data: Data?
    func fetch(key: String) -> Data? {
        didFetch = true
        return data
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

class FakeJSONEncoder: JSONEncoder {
    private let encodedData: Data?
    
    public init(encodedData: Data? = nil) {
        self.encodedData = encodedData
    }
    
    override func encode<T>(_ value: T) throws -> Data where T : Encodable {
        guard let encodedData = encodedData else {
            throw FakeEncoderError.any
        }
        return encodedData
    }
    
    private enum FakeEncoderError: Error {
        case any
    }
}

class FakeJSONDecoder<T>: JSONDecoder {
    private let decodedData: T?
    
    public init(decodedData: T? = nil) {
        self.decodedData = decodedData
    }
    
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard T.self == type else { throw FakeDecoderError.any }
        guard let decodedData = decodedData, let dataFrom = decodedData as? T else {
            throw FakeDecoderError.any
        }
        return dataFrom
    }
    
    private enum FakeDecoderError: Error {
        case any
    }
}
