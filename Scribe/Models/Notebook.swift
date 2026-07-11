// Notebook.swift
// Scribe — SwiftData model for notebooks

import Foundation
import SwiftData

@Model
final class Notebook {
    
    // MARK: - Properties
    
    var id: UUID
    var title: String
    var coverColorHex: String
    var emoji: String?
    var createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    var isArchived: Bool
    var colorLabel: String?
    var sortOrder: Int
    var notebookDescription: String?
    
    // MARK: - Relationships
    
    /// All sections within this notebook, ordered by sortOrder
    @Relationship(deleteRule: .cascade, inverse: \Section.notebook)
    var sections: [Section]?
    
    // MARK: - Computed
    
    var sortedSections: [Section] {
        (sections ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var pageCount: Int {
        (sections ?? []).reduce(0) { $0 + ($1.pages?.count ?? 0) }
    }
    
    // MARK: - Init
    
    init(
        title: String,
        coverColor: String = "#5B7FFF",
        emoji: String? = "📓"
    ) {
        self.id = UUID()
        self.title = title
        self.coverColorHex = coverColor
        self.emoji = emoji
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isFavorite = false
        self.isArchived = false
        self.sortOrder = 0
    }
    
    // MARK: - Methods
    
    func touch() {
        self.modifiedAt = Date()
    }
}
