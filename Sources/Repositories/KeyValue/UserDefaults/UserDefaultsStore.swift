import Foundation
import PelicanProtocols

public struct UserDefaultsStore: KeyValueStore {
    private let userDefaults: UserDefaults
    private let logger: Logger?
    
    public init(userDefaults: UserDefaults, logger: Logger? = nil) {
        self.userDefaults = userDefaults
        self.logger = logger
    }
    
    public func save(data: Data, key: String) -> Bool {
        logger?.debug("📱UserDefaultsLayer📱 - saving data for key: \(key)")
        userDefaults.set(data, forKey: key)
        return userDefaults.synchronize()
    }
    
    public func update(data: Data, key: String) -> Bool {
        logger?.debug("📱UserDefaultsLayer📱 - updating data for key: \(key)")
        return save(data: data, key: key)
    }
    
    public func delete(key: String) -> Bool {
        logger?.debug("📱UserDefaultsLayer📱 - deleting data for key: \(key)")
        userDefaults.removeObject(forKey: key)
        return userDefaults.object(forKey: key) == nil
    }
    
    public func fetch(key: String) -> Data? {
        logger?.debug("📱UserDefaultsLayer📱 - fetching data for key: \(key)")
        return userDefaults.data(forKey: key)
    }
}
