//
//  FileCacheDB.swift
//  Pelican
//
//  Created by Daniel Koster on 4/13/26.
//
import SwiftData
import PelicanProtocols

import Foundation
import SwiftData

@MainActor
class DataController {
    static let shared = DataController()
    
    let container: ModelContainer
    
    private init() {
        do {
            let schema = Schema(versionedSchema: CacheSchemaV1.self)
            let config = ModelConfiguration(
                "ProductionStore",
                schema: schema,
                url: FileCacheDirectory.dbURL,
                allowsSave: true
            )
            
            // Initialize the container statically
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
}
/*
 // MARK: - Schema V1 (Original)
 enum AppSchemaV1: VersionedSchema {
     static var versionIdentifier = Schema.Version(1, 0, 0)
     static var models: [any PersistentModel.Type] { [User.self, Post.self] }

     @Model
     class User { var name: String; init(name: String) { self.name = name } }

     @Model
     class Post { var title: String; init(title: String) { self.title = title } }
 }

 // MARK: - Schema V2 (Current)
 enum AppSchemaV2: VersionedSchema {
     static var versionIdentifier = Schema.Version(1, 1, 0)
     
     // POINTING TO PREVIOUS MODELS:
     // We define a new User, but we re-use the Post from V1
     static var models: [any PersistentModel.Type] {
         [User.self, AppSchemaV1.Post.self]
     }

     @Model
     class User {
         var name: String
         var email: String = "" // New property for V2
         init(name: String, email: String) { self.name = name; self.email = email }
     }
 }

 */

/*
 import SwiftUI
 import SwiftData

 @main
 struct ProductionApp: App {
     // Shared container instance
     let container: ModelContainer

     init() {
         do {
             // 1. Explicitly define your Schema for version control
             let schema = Schema([
                 User.self,
                 Settings.self
             ])
             
             // 2. Production ModelConfiguration
             let config = ModelConfiguration(
                 "ProductionStore", // Named store for easier identification
                 schema: schema,
                 isStoredInMemoryOnly: false,
                 allowsSave: true,
                 cloudKitDatabase: .automatic // Enables CloudKit syncing
             )
             
             // 3. Initialize with potential SchemaMigrationPlan
             // Replace 'nil' with your migration class when schema changes
             container = try ModelContainer(
                 for: schema,
                 migrationPlan: nil,
                 configurations: [config]
             )
         } catch {
             // 4. Production Error Handling
             // In a real app, log this to a service like Sentry or CloudWatch.
             // Avoid fatalError() here; instead, show a 'Recovery' view if possible.
             print("Failed to initialize ModelContainer: \(error.localizedDescription)")
             fatalError("Unresolved error: \(error)")
         }
     }

     var body: some Scene {
         WindowGroup {
             ContentView()
         }
         .modelContainer(container)
     }
 }

 */
