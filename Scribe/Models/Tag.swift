// Tag.swift
// Scribe — SwiftData model for tags

import Foundation
import SwiftData

@Model
final class Tag {
    
    // MARK: - Properties
    
    var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date
    
    // MARK: - Relationships
    
    @Relationship(inverse: \Page.tags)
    var pages: [Page]?
    
    // MARK: - Init
    
    init(name: String, colorHex: String = "#FF6B6B") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}
