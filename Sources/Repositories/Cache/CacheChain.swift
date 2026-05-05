//
//  CacheChain.swift
//  Pelican
//
//  Created by Daniel Koster on 5/5/26.
//

import Foundation
import PelicanProtocols

public actor CacheChain: Cache {
    private let cache: Cache
    private let next: Cache?
    
    public init(cache: Cache, next: Cache? = nil) {
        self.cache = cache
        self.next = next
    }
    
    public func save(_ data: PelicanProtocols.CacheData) async throws {
        do {
            try await cache.save(data)
        } catch {
            try await next?.save(data)
        }
    }
    
    public func remove(_ data: PelicanProtocols.CacheData) async throws {
        do {
            try await cache.remove(data)
        } catch {
            try await next?.remove(data)
        }
    }
    
    public func find(_ byName: String) async -> PelicanProtocols.CacheData? {
        if let record = await cache.find(byName) {
            return record
        }
        return await next?.find(byName)
    }
    
    public func removeAll() async throws {
        try await cache.removeAll()
        try await next?.removeAll()
    }
    
}
