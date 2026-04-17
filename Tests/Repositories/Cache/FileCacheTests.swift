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

class FileCacheTests {
    
    @Test func addFileToCache() async throws {
        try removeCacheDirectory()
        let sut = FileCache(policies: [])
//        let modelContainer = CacheDB.shared.container
//        let sut = FileCache(fileManager: .default, policies: [], modelContainer: modelContainer)
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
        try removeCacheDirectory()
    }
    
    private func removeCacheDirectory() throws {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: URL.cachesDirectory.appending(component: "Pelican"))
            let contents = try FileManager.default.contentsOfDirectory(
                at: URL.cachesDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            for content in contents {
                print("Found content: \(content.lastPathComponent)")
            }
        }
        catch let error {
            print(error)
        }
    }
}
