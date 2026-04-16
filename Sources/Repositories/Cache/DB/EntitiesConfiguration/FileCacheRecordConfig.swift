//
//  FileCacheRecordConfig.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import Foundation
import PelicanProtocols
import SwiftData

extension FileCacheRecord: PersistenModelConvertible {
    init(from: FileCacheRecordEntity) {
        self.init(contentURL: from.contentURL, name: from.name, id: from.uuid, createdAt: from.createdAt)
    }
    
    func asEntity() -> FileCacheRecordEntity {
        FileCacheRecordEntity(uuid: id, name: name, contentURL: contentURL, createdAt: createdAt)
    }
    
    func merge(into: FileCacheRecordEntity) {
        into.name = name
        into.contentURL = contentURL
    }
    
    var identifiablePredicate: Predicate<FileCacheRecordEntity> {
        let uuid = id
        return #Predicate { element in
            element.uuid == uuid
        }
    }
    
    typealias SwiftDataEntity = FileCacheRecordEntity
    
    
}
