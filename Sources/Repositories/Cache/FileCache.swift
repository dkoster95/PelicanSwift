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
                  logger: PelicanLogger(subsystem: "Pelican.Cache", category: "FileCache"),
                  repository: SwiftDataRepository<FileCacheRecord>(modelContainer: modelContainer))
    }
    
    init(policies: [CachePolicy]) {
        let container = CacheDB.shared.container
        self.init(fileManager: .default,
                  policies: policies,
                  logger: PelicanLogger(subsystem: "Pelican.Cache", category: "FileCache"),
                  repository: SwiftDataRepository<FileCacheRecord>(modelContainer: container))
    }
}

extension SwiftDataRepository<FileCacheRecord>: FileCacheRepository {}

protocol FileCacheRepository: AsyncInsertableRepository, AsyncPredicableReadableRepository, AsyncDeleteableRepository where Element == FileCacheRecord, PersistibleElement ==  FileCacheRecordEntity, ResultElement == FileCacheRecord {}

public actor FileCache: Cache {
    private let fileManager: FileManager
    private let policies: [CachePolicy]
    private let logger: Logger
    private let repository: any FileCacheRepository
    private var activeMutations = Set<String>()
    
    init(fileManager: FileManager,
         policies: [CachePolicy],
         logger: Logger,
         repository: any FileCacheRepository) {
        self.fileManager = fileManager
        self.policies = policies
        self.repository = repository
        self.logger = logger
    }
    
    public func save(_ data: PelicanProtocols.CacheData) async throws {
        logger.debug("checking policies")
        guard !activeMutations.contains(data.name) else { return }
        for policy in policies {
            do {
                _ = try policy.isValid(data)
            } catch let error {
                logger.error("policy \(policy) failed validating: \(error)")
                throw error
            }
        }
        activeMutations.insert(data.name)
        defer { activeMutations.remove(data.name) }
        try await fileManager.createDirectoryAsync(at: FileCacheDirectory.filesURL, withIntermediateDirectories: true, attributes: nil)
        let contentURL = FileCacheDirectory.filesURL.appending(component: data.id.uuidString)
        logger.debug("Content url for file \(contentURL)")
        logger.debug("File size: \(data.content.count) bytes")

        let record = FileCacheRecord(contentURL: contentURL,
                                     name: data.name,
                                     id: data.id,
                                     createdAt: data.createdAt)
        try await data.content.writeAsync(to: contentURL, options: [.atomic, .completeFileProtection])
        logger.debug("data saved to file")
        let result = try await repository.add(element: record)
        logger.debug("record added to DB \(result.name)")
    }
    
    public func remove(_ data: CacheData) async throws {
        guard !activeMutations.contains(data.name) else { return }
        let name = data.name
        activeMutations.insert(name)
        defer {
            activeMutations.remove(name)
        }
        let predicate = #Predicate<FileCacheRecordEntity> { element in
            element.name == name
        }
        if let result = await repository.find(predicate: predicate, sortBy: nil).first {
            logger.debug("record found: proceeding to delete cache record")
            let contentURL = FileCacheDirectory.filesURL.appending(component: result.id.uuidString)
            try await fileManager.remove(at: contentURL)
            try await repository.delete(element: result)
        }
    }
    
    public func find(_ byName: String) async -> CacheData? {
        logger.debug("Finding cache record...")
        let predicate = #Predicate<FileCacheRecordEntity> { element in
            element.name == byName
        }
        if activeMutations.contains(byName) {
            return nil
        }
        guard let result = await repository.find(predicate: predicate,
                                                 sortBy: nil).first else {
            logger.debug("Cache record not found in repository")
            return nil
        }
        guard !activeMutations.contains(byName) else { return nil }
        do {
            let contentURL = FileCacheDirectory.filesURL.appending(component: result.id.uuidString)
            let content = try Data(contentsOf: contentURL, options: .mappedIfSafe)
//            guard let content = try await Data.read(from: contentURL) else {
//                logger.error("Cache record exists in database, but file data failed to read")
//                return nil
//            }
            logger.debug("cache recourd found")
            return CacheData(content: content, name: result.name, id: result.id, createdAt: result.createdAt)
        } catch CocoaError.fileReadNoSuchFile {
            logger.debug("File was removed by concurrent task")
            return nil
        } catch {
            logger.error("Unexpected error while reading the file")
            return nil
        }
    }
    
    public func removeAll() async throws {
        logger.debug("Removing all cache in file")
        var isDirectory: ObjCBool = true
        guard fileManager.fileExists(atPath: FileCacheDirectory.filesURL.path(), isDirectory: &isDirectory) else { return }
        logger.debug("Files folder detected, proceeding to delete all")
        try fileManager.removeItem(at: FileCacheDirectory.filesURL)
        logger.debug("Files folder deleted, proceeding to delete all records in DB")
        try await repository.deleteAll()
    }
    
}

extension Data {
    nonisolated static func read(from url: URL) async throws -> Data? {
        return try? Data(contentsOf: url, options: .mappedIfSafe)
    }
    
    nonisolated func writeAsync(to url: URL, options: Data.WritingOptions = []) async throws {
        try write(to: url, options: options)
    }
}

extension FileManager {
    nonisolated func remove(at: URL) async throws {
        if fileExists(atPath: at.path) {
            try removeItem(at: at)
        }
    }
    
    nonisolated func exists(at: URL) async throws -> Bool {
        fileExists(atPath: at.path)
    }
    
    nonisolated func createDirectoryAsync(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) async throws {
        try createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes)
    }
}
