//
//  FileCache.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import Foundation
import PelicanProtocols

public actor FileCache: Cache, @unchecked Sendable {
    private let fileManager: FileManager
    private let policies: [CachePolicy]
    private let repository: any AsyncInsertableRepository<FileCacheRecord>
    
    private var baseURL: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appending(component: "Pelican")
            .appending(component: "cache")
            .appending(component: "files")
    }
    
    public init(fileManager: FileManager,
                policies: [CachePolicy],
                repository: any AsyncInsertableRepository<FileCacheRecord>) {
        self.fileManager = fileManager
        self.policies = policies
        self.repository = repository
    }
    
    public func save(_ data: PelicanProtocols.CacheData) async throws {
        for policy in policies {
            do {
                _ = try policy.isValid(data)
            } catch CacheError.sizeLimit {
                // remove size in order to implement
            }
            catch let error {
                throw error
            }
        }
        try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true, attributes: nil)
        let contentURL = baseURL.appending(component: data.id.uuidString)

        let record = FileCacheRecord(contentURL: contentURL,
                                     name: data.name,
                                     id: data.id,
                                     createdAt: data.createdAt)
        let result = try await repository.add(element: record)
        try data.content.write(to: contentURL, options: [.atomic, .completeFileProtection])
        // create record in db
        // save data to file in cache dir
        
    }
    
    public func remove(_ data: CacheData) async throws {
        
    }
    
    public func find(_ byName: String) async -> CacheData? {
        // find record in repo by name
        // find file by id
        // create CacheData
        return nil
    }
    
    public func removeAll() async {
        
    }
    
}
