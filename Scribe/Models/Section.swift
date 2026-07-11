// Section.swift
// Scribe — SwiftData model for notebook sections

import Foundation
import SwiftData

@Model
final class Section {
    
    // MARK: - Properties
    
    var id: UUID
    var title: String
    var sortOrder: Int
    var colorHex: String?
    var createdAt: Date
    var modifiedAt: Date
    
    // MARK: - Relationships
    
    var notebook: Notebook?
    
    @Relationship(deleteRule: .cascade, inverse: \Page.section)
    var pages: [Page]?
    
    // MARK: - Computed
    
    var sortedPages: [Page] {
        (pages ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: - Init
    
    init(
        title: String,
        sortOrder: Int = 0,
        colorHex: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.sortOrder = sortOrder
        self.colorHex = colorHex
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    func touch() {
        self.modifiedAt = Date()
    }
}
