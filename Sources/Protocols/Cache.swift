//
//  Cache.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import Foundation

public struct CacheData: Sendable {
    public let content: Data
    public let name: String
    public let id: UUID
    public let createdAt: Date

    public init(content: Data,
                name: String,
                id: UUID = UUID(),
                createdAt: Date = Date()) {
        self.content = content
        self.name = name
        self.id = id
        self.createdAt = createdAt
    }
}

public struct FileCacheRecord: Sendable {
    public let contentURL: URL
    public let name: String
    public let id: UUID
    public let createdAt: Date
    
    public init(contentURL: URL, name: String, id: UUID, createdAt: Date) {
        self.contentURL = contentURL
        self.name = name
        self.id = id
        self.createdAt = createdAt
    }
}

public protocol CachePolicy: Sendable {
    func isValid(_ data: CacheData) throws -> Bool
}

public protocol Cache: Sendable {
    func save(_ data: CacheData) async throws
    func remove(_ data: CacheData) async throws
    func find(_ byName: String) async -> CacheData?
    func removeAll() async
}

public enum CacheError: Error, Sendable {
    case sizeLimit
    case expired
}
