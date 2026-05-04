//
//  FileCacheTests.swift
//  Pelican
//
//  Created by Daniel Koster on 4/16/26.
//
import PelicanRepositories
import PelicanProtocols
import Foundation
import Testing

@Suite(.serialized)
class FileCacheTests {
    
    @Test func addFileToCache() async throws {
        let sut = FileCache(policies: [])
        let imagePath = URL(fileURLWithPath: Bundle.module.path(forResource: "swifticon", ofType: "png")!)
        let imageData = try Data(contentsOf: imagePath)
        let cacheData = CacheData(content: imageData, name: "swifticon")

        try await sut.save(cacheData)
        
        let result = await sut.find("swifticon")
        #expect(result != nil)
        
        try await sut.remove(cacheData)
        let resultAfterDeleted = await sut.find("swifticon")
        #expect(resultAfterDeleted == nil)
        
        try await sut.removeAll()
    }
    
    @Test func removeFileToCache() async throws {
        let sut = FileCache(policies: [])
        try await sut.removeAll()
        let imagePath = URL(fileURLWithPath: Bundle.module.path(forResource: "swifticon", ofType: "png")!)
        let imageData = try Data(contentsOf: imagePath)
        let cacheData = CacheData(content: imageData, name: "swifticon")
        
        try await sut.save(cacheData)
        
        let cachedDataSaved = try #require(await sut.find(cacheData.name))
        #expect(cachedDataSaved.name == "swifticon")
        try await sut.remove(cacheData)
        
        let findCached = await sut.find("swifticon")
        #expect(findCached == nil)
        
        try await sut.removeAll()
    }
    
    @Test func sizeCachePolicy() async throws {
        let sut = FileCache(policies: [SizeCachePolicy(maxSize: 15000, fileManager: .default)])
        try await sut.removeAll()
        let imagePath = URL(fileURLWithPath: Bundle.module.path(forResource: "swifticon", ofType: "png")!)
        let imageData = try Data(contentsOf: imagePath)
        let cacheData = CacheData(content: imageData, name: "swifticon")
        let cacheDataSecond = CacheData(content: imageData, name: "swifticon2")
        let cacheDataThird = CacheData(content: imageData, name: "swifticon2")
        
        try await sut.save(cacheData)
        
        let cachedDataSaved = try #require(await sut.find(cacheData.name))
        #expect(cachedDataSaved.name == "swifticon")
        
        try await sut.save(cacheDataSecond)
        
        let findCached = await sut.find("swifticon2")
        #expect(findCached != nil)
        
        await #expect(throws: CacheError.sizeLimit) {
            try await sut.save(cacheDataThird)
        }
        
        try await sut.removeAll()
    }
    
    @Test func expirationCachePolicy_whenExpired_expectException() async throws {
        let expirationPolicy = ExpirationCachePolicy { date in
            let calendar = Calendar.current
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: date) {
                return yesterday
            }
            return date
        }
        let sut = FileCache(policies: [expirationPolicy])
        try await sut.removeAll()
        let imagePath = URL(fileURLWithPath: Bundle.module.path(forResource: "swifticon", ofType: "png")!)
        let imageData = try Data(contentsOf: imagePath)
        let cacheData = CacheData(content: imageData, name: "swifticon")
        
        await #expect(throws: CacheError.expired) {
            try await sut.save(cacheData)
        }
        
        try await sut.removeAll()
    }
    
    @Test func expirationCachePolicy() async throws {
        let expirationPolicy = ExpirationCachePolicy { date in
            let calendar = Calendar.current
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) {
                return tomorrow
            }
            return date
        }
        let sut = FileCache(policies: [expirationPolicy])
        try await sut.removeAll()
        let imagePath = URL(fileURLWithPath: Bundle.module.path(forResource: "swifticon", ofType: "png")!)
        let imageData = try Data(contentsOf: imagePath)
        let cacheData = CacheData(content: imageData, name: "swifticon")
        
        try await sut.save(cacheData)
        let cachedDataSaved = try #require(await sut.find(cacheData.name))
        
        #expect(cachedDataSaved.name == "swifticon")
        
        try await sut.removeAll()
    }
    
}
