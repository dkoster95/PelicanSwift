//
//  MemoryCacheTests.swift
//  Pelican
//
//  Created by Daniel Koster on 5/5/26.
//

import PelicanProtocols
import Foundation
import Testing
import PelicanRepositories


@Suite struct MemoryCacheTests {
    

    private func makeSUT(policies: [CachePolicy] = []) -> (MemoryCache, InMemoryRepository<CacheData>) {
        let repo = InMemoryRepository<CacheData>()
        let sut = MemoryCache(policies: policies, repository: repo)
        return (sut, repo)
    }

    @Test("Saving data succeeds when all policies are valid")
    func saveSucceeds() async throws {
        let (sut, _) = makeSUT()
        let data = CacheData(content: Data(), name: "valid-item")
        
        try await sut.save(data)
        
        let found = await sut.find("valid-item")
        #expect(found != nil)
        #expect(found?.name == "valid-item")
    }

    @Test("Saving data fails and throws error when a policy is invalid")
    func saveFailsOnPolicyViolation() async throws {
        let expirationPolicy = ExpirationCachePolicy { date in
            let calendar = Calendar.current
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: date) {
                return yesterday
            }
            return date
        }
        let (sut, _) = makeSUT(policies: [expirationPolicy])
        let data = CacheData(content: Data(), name: "valid-item")


        await #expect(throws: CacheError.expired) {
            try await sut.save(data)
        }
    }

    @Test("Finding an item returns nil if it doesn't exist")
    func findReturnsNil() async {
        let (sut, _) = makeSUT()
        
        let result = await sut.find("missing-name")
        
        #expect(result == nil)
    }

    @Test("Remove all clears the entire cache")
    func removeAllClearsCache() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(CacheData(content: Data(), name: "item1"))
        try await sut.save(CacheData(content: Data(), name: "item2"))

        try await sut.removeAll()

        let item1 = await sut.find("item1")
        let item2 = await sut.find("item2")
        #expect(item1 == nil)
        #expect(item2 == nil)
    }

    @Test("Removing specific data deletes it from the repository")
    func removeSpecificData() async throws {
        let (sut, _) = makeSUT()
        let data = CacheData(content: Data(), name: "delete-me")
        try await sut.save(data)
        
        try await sut.remove(data)
        
        let result = await sut.find("delete-me")
        #expect(result == nil)
    }
}

