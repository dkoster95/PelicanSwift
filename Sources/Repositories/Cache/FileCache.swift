//
//  FileCache.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import Foundation
import PelicanProtocols
import SwiftData

struct FileCacheRecord: Sendable, Equatable {
    let contentURL: URL
    let name: String
    let id: UUID
    let createdAt: Date
    
    init(contentURL: URL, name: String, id: UUID, createdAt: Date) {
        self.contentURL = contentURL
        self.name = name
        self.id = id
        self.createdAt = createdAt
    }
}

struct FileCacheDirectory {
    static let baseURL: URL = URL.cachesDirectory.pelican
    static let filesURL: URL = baseURL.files
    static let dbURL: URL = baseURL.db
}

extension URL {
    var pelican: URL {
        appending(component: "Pelican")
    }
    
    var files: URL {
        appending(component: "files")
    }
    
    var db: URL {
        appending(path: "PelicanCache.sqlite")
    }
}

public extension FileCache {
    init(fileManager: FileManager,
         policies: [CachePolicy],
         modelContainer: ModelContainer) {
        self.init(fileManager: fileManager,
                  policies: policies) {
            SwiftDataRepository<FileCacheRecord>(modelContainer: modelContainer)
        }
    }
}

public actor FileCache: Cache, @unchecked Sendable {
    private let fileManager: FileManager
    private let policies: [CachePolicy]
    private let repositoryBuilder: () -> any AsyncInsertableRepository<FileCacheRecord>
    
    init(fileManager: FileManager,
         policies: [CachePolicy],
         repositoryBuilder: @escaping () -> any AsyncInsertableRepository<FileCacheRecord>) {
        self.fileManager = fileManager
        self.policies = policies
        self.repositoryBuilder = repositoryBuilder
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
        try fileManager.createDirectory(at: FileCacheDirectory.filesURL, withIntermediateDirectories: true, attributes: nil)
        let contentURL = FileCacheDirectory.filesURL.appending(component: data.id.uuidString)

        let record = FileCacheRecord(contentURL: contentURL,
                                     name: data.name,
                                     id: data.id,
                                     createdAt: data.createdAt)
        let repository = repositoryBuilder()
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
