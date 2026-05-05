//
//  MemoryCache.swift
//  Pelican
//
//  Created by Daniel Koster on 5/4/26.
//

import PelicanProtocols
import Foundation

public actor MemoryCache: Cache, Sendable {
    private let policies: [CachePolicy]
    private let repository: InMemoryRepository<CacheData>
    private let logger: Logger
    
    public init(policies: [CachePolicy],
                repository: InMemoryRepository<CacheData>,
                logger: Logger) {
        self.policies = policies
        self.repository = repository
        self.logger = logger
    }
    
    public init(policies: [CachePolicy],
                repository: InMemoryRepository<CacheData>) {
        self.init(policies: policies, repository: repository, logger: PelicanLogger(subsystem: "Memory Cache", category: "Caches"))
    }
    
    public func save(_ data: PelicanProtocols.CacheData) async throws {
        logger.debug("checking policies")
        for policy in policies {
            do {
                _ = try policy.isValid(data)
            } catch let error {
                logger.error("policy \(policy) failed validating: \(error)")
                throw error
            }
        }
        _ = try repository.add(element: data)
    }
    
    public func remove(_ data: PelicanProtocols.CacheData) async throws {
        logger.debug("removing element from cache")
        try repository.delete(element: data)
    }
    
    public func find(_ byName: String) async -> PelicanProtocols.CacheData? {
        logger.debug("finding cache record by name")
        if let record = repository.find (query: { data in data.name == byName }).first {
            logger.debug("Record found in memory cache")
            return record
        }
        logger.debug("no record found in cache")
        return nil
    }
    
    public func removeAll() async throws {
        logger.debug("Removing all data from memory cache")
        try repository.deleteAll()
    }
    
}
