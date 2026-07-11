// MigrationManager.swift
// Scribe — SwiftData schema versioning and migration

import Foundation
import SwiftData
import OSLog

/// Handles schema migrations as the data model evolves
enum MigrationManager {
    
    // MARK: - Schema Versions
    
    /// v1: Initial schema
    enum SchemaV1: VersionedSchema {
        static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
        
        static var models: [any PersistentModel.Type] {
            [Notebook.self, Section.self, Page.self, Tag.self, MediaAttachment.self]
        }
    }
    
    // MARK: - Migration Plan
    
    enum MigrationPlan: SchemaMigrationPlan {
        static var schemas: [any VersionedSchema.Type] {
            [SchemaV1.self]
        }
        
        static var stages: [MigrationStage] {
            // No migrations needed yet — only one schema version
            []
        }
    }
    
    // MARK: - Container Factory
    
    /// Create a ModelContainer with migration support
    static func createContainer() throws -> ModelContainer {
        let schema = Schema(SchemaV1.models)
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        let container = try ModelContainer(
            for: schema,
            migrationPlan: MigrationPlan.self,
            configurations: [configuration]
        )
        
        Logger.storage.info("ModelContainer created with migration support")
        
        return container
    }
}
