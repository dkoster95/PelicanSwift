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
                  policies: policies,
                  logger: PelicanLogger(subsystem: "Pelican.Cache", category: "FileCache")) {
            SwiftDataRepository<FileCacheRecord>(modelContainer: modelContainer)
        }
    }
    
    init(policies: [CachePolicy]) {
        let container = CacheDB.shared.container
        self.init(fileManager: .default,
                  policies: policies,
                  logger: PelicanLogger(subsystem: "Pelican.Cache", category: "FileCache")) {
            SwiftDataRepository<FileCacheRecord>(modelContainer: container)
        }
    }
}

typealias FileCacheRepository = AsyncInsertableRepository<FileCacheRecord> & AsyncPredicableReadableRepository<FileCacheRecordEntity, FileCacheRecord> & AsyncDeleteableRepository<FileCacheRecord>

public actor FileCache: Cache, @unchecked Sendable {
    private let fileManager: FileManager
    private let policies: [CachePolicy]
    private let logger: Logger
    private let repositoryBuilder: () -> any FileCacheRepository
    
    init(fileManager: FileManager,
         policies: [CachePolicy],
         logger: Logger,
         repositoryBuilder: @escaping () -> any FileCacheRepository) {
        self.fileManager = fileManager
        self.policies = policies
        self.repositoryBuilder = repositoryBuilder
        self.logger = logger
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
        try fileManager.createDirectory(at: FileCacheDirectory.filesURL, withIntermediateDirectories: true, attributes: nil)
        let contentURL = FileCacheDirectory.filesURL.appending(component: data.id.uuidString)
        logger.debug("Content url for file \(contentURL)")

        let record = FileCacheRecord(contentURL: contentURL,
                                     name: data.name,
                                     id: data.id,
                                     createdAt: data.createdAt)
        let repository = repositoryBuilder()
        let result = try await repository.add(element: record)
        logger.debug("record added to DB \(result.name)")
        try data.content.write(to: contentURL, options: [.atomic, .completeFileProtection])
        logger.debug("data saved to file")
        let contents = try FileManager.default.contentsOfDirectory(
            at: URL.cachesDirectory.pelican,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        for content in contents {
            logger.debug("Found content: \(content.lastPathComponent)")
        }
    }
    
    public func remove(_ data: CacheData) async throws {
        let repository = repositoryBuilder()
        let name = data.name
        let predicate = #Predicate<FileCacheRecordEntity> { element in
            element.name == name
        }
        if let result = await repository.find(predicate: predicate, sortBy: nil).first {
            try await repository.delete(element: result)
            try fileManager.removeItem(at: result.contentURL)
        }
    }
    
    public func find(_ byName: String) async -> CacheData? {
        let repository = repositoryBuilder()
        let predicate = #Predicate<FileCacheRecordEntity> { element in
            element.name == byName
        }
        if let result = await repository.find(predicate: predicate,
                                              sortBy: nil).first,
           let content = try? Data(contentsOf: result.contentURL, options: .mappedIfSafe) {
            return CacheData(content: content, name: result.name, id: result.id, createdAt: result.createdAt)
        }
        return nil
    }
    
    public func removeAll() async throws {
        try fileManager.removeItem(at: FileCacheDirectory.filesURL)
        let repository = repositoryBuilder()
        try await repository.deleteAll()
    }
    
}
