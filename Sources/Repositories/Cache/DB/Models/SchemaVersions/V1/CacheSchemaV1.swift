//
//  SchemaV1.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import Foundation
import SwiftData


enum CacheSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }
    static var models: [any PersistentModel.Type] {
        [FileCacheRecordEntity.self]
    }
}

/*
 enum AppMigrationPlan: SchemaMigrationPlan {
     static var schemas: [any VersionedSchema.Type] {
         [SchemaV1.self, SchemaV2.self, SchemaV3.self] // All versions in order
     }

     static var stages: [MigrationStage] {
         [migrateV1toV2, migrateV2toV3] // The steps to get to the latest
     }

     static let migrateV1toV2 = MigrationStage.lightweight(
         fromVersion: SchemaV1.self,
         toVersion: SchemaV2.self
     )

     static let migrateV2toV3 = MigrationStage.lightweight(
         fromVersion: SchemaV2.self,
         toVersion: SchemaV3.self
     )
 }

 */


