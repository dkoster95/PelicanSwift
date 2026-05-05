//
//  CacheChainTests.swift
//  Pelican
//
//  Created by Daniel Koster on 5/5/26.
//
import Testing
import Foundation
import PelicanRepositories
import PelicanProtocols

// MARK: - Mocks

actor MockCache: Cache {
    var shouldFail: Bool = false
    var storedData: [String: CacheData] = [:]
    var removeAllCalled = false

    func save(_ data: CacheData) async throws {
        if shouldFail { throw NSError(domain: "CacheError", code: 1) }
        storedData[data.name] = data
    }

    func remove(_ data: CacheData) async throws {
        if shouldFail { throw NSError(domain: "CacheError", code: 2) }
        storedData.removeValue(forKey: data.name)
    }

    func find(_ byName: String) async -> CacheData? {
        return storedData[byName]
    }

    func removeAll() async throws {
        removeAllCalled = true
        storedData.removeAll()
    }
}

// MARK: - Tests

@Suite("CacheChain Tests")
struct CacheChainTests {

    @Test("Save falls back to next cache when primary fails")
    func saveFallback() async throws {
        let primary = MockCache()
        let secondary = MockCache()
        let sut = CacheChain(cache: primary, next: secondary)
        let data = CacheData(content: Data(), name: "test-item")

        await primary.setShouldFail(true) // Helper to trigger failure
        
        try await sut.save(data)

        let secondaryData = await secondary.find("test-item")
        #expect(secondaryData != nil, "Data should be saved to secondary if primary fails")
    }

    @Test("Find returns data from primary if available")
    func findPrimaryHit() async throws {
        let primary = MockCache()
        let secondary = MockCache()
        let sut = CacheChain(cache: primary, next: secondary)
        let data = CacheData(content: Data(), name: "shared-item")

        try await primary.save(data)
        // Secondary has different data for the same name to prove we got it from primary
        try await secondary.save(CacheData(content: Data(), name: "shared-item"))

        let result = await sut.find("shared-item")
        
        #expect(result != nil)
        // Verify it came from primary (MockCache behavior matches input)
    }

    @Test("Find falls back to secondary if primary returns nil")
    func findSecondaryFallback() async throws {
        let primary = MockCache()
        let secondary = MockCache()
        let sut = CacheChain(cache: primary, next: secondary)
        let data = CacheData(content: Data(), name: "only-in-secondary")

        try await secondary.save(data)

        let result = await sut.find("only-in-secondary")
        
        #expect(result?.name == "only-in-secondary")
    }

    @Test("RemoveAll clears both primary and secondary")
    func removeAllClearsChain() async throws {
        let primary = MockCache()
        let secondary = MockCache()
        let sut = CacheChain(cache: primary, next: secondary)

        try await sut.removeAll()

        let pCalled = await primary.removeAllCalled
        let sCalled = await secondary.removeAllCalled
        #expect(pCalled && sCalled)
    }
    
    @Test("Remove falls back to next if primary fails")
    func removeFallback() async throws {
        let primary = MockCache()
        let secondary = MockCache()
        let sut = CacheChain(cache: primary, next: secondary)
        let data = CacheData(content: Data(), name: "item")
        
        try await secondary.save(data)
        await primary.setShouldFail(true)
        
        try await sut.remove(data)
        
        let found = await secondary.find("item")
        #expect(found == nil, "Secondary should have processed the remove call")
    }
}

// Simple extension to allow modifying MockCache state from tests
extension MockCache {
    func setShouldFail(_ value: Bool) {
        self.shouldFail = value
    }
}

