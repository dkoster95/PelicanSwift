//
//  FileCacheRecord.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import Foundation
import SwiftData

extension CacheSchemaV1 {
    @Model
    class FileCacheRecordEntity {
        @Attribute(.unique) var uuid: UUID
        var name: String
        var contentURL: URL
        var createdAt: Date
        
        init(uuid: UUID, name: String, contentURL: URL, createdAt: Date) {
            self.uuid = uuid
            self.name = name
            self.contentURL = contentURL
            self.createdAt = createdAt
        }
    }
}

