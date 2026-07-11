// SmartCollectionService.swift
// Scribe — Dynamic smart collections based on rules

import Foundation
import SwiftData

@MainActor
final class SmartCollectionService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Built-in Collections
    
    enum SmartCollection: String, CaseIterable, Identifiable {
        case recentlyModified = "Recently Modified"
        case recentlyCreated = "Recently Created"
        case favorites = "Favorites"
        case withDrawings = "Pages with Drawings"
        case emptyPages = "Empty Pages"
        case pdfAnnotated = "PDF Annotations"
        case tagged = "Tagged Pages"
        case untagged = "Untagged Pages"
        
        var id: String { rawValue }
        
        var systemImage: String {
            switch self {
            case .recentlyModified: return "clock.arrow.circlepath"
            case .recentlyCreated: return "sparkles"
            case .favorites: return "heart.fill"
            case .withDrawings: return "pencil.and.scribble"
            case .emptyPages: return "doc"
            case .pdfAnnotated: return "doc.text"
            case .tagged: return "tag.fill"
            case .untagged: return "tag.slash"
            }
        }
    }
    
    func fetchPages(for collection: SmartCollection, limit: Int = 50) throws -> [Page] {
        switch collection {
        case .recentlyModified:
            var descriptor = FetchDescriptor<Page>(
                sortBy: [SortDescriptor(\Page.modifiedAt, order: .reverse)]
            )
            descriptor.fetchLimit = limit
            return try modelContext.fetch(descriptor)
            
        case .recentlyCreated:
            var descriptor = FetchDescriptor<Page>(
                sortBy: [SortDescriptor(\Page.createdAt, order: .reverse)]
            )
            descriptor.fetchLimit = limit
            return try modelContext.fetch(descriptor)
            
        case .favorites:
            let descriptor = FetchDescriptor<Notebook>(
                predicate: #Predicate { $0.isFavorite && !$0.isArchived }
            )
            let notebooks = try modelContext.fetch(descriptor)
            return notebooks.flatMap { $0.sortedSections.flatMap { $0.sortedPages } }
            
        case .withDrawings:
            let descriptor = FetchDescriptor<Page>(
                predicate: #Predicate<Page> { $0.drawingData != nil },
                sortBy: [SortDescriptor(\Page.modifiedAt, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
            
        case .emptyPages:
            let descriptor = FetchDescriptor<Page>(
                predicate: #Predicate<Page> { $0.drawingData == nil },
                sortBy: [SortDescriptor(\Page.createdAt, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
            
        case .pdfAnnotated:
            let descriptor = FetchDescriptor<Page>(
                predicate: #Predicate<Page> { $0.isPDFPage },
                sortBy: [SortDescriptor(\Page.modifiedAt, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
            
        case .tagged:
            // Fetch all pages then filter for those with tags
            let descriptor = FetchDescriptor<Page>(
                sortBy: [SortDescriptor(\Page.modifiedAt, order: .reverse)]
            )
            let allPages = try modelContext.fetch(descriptor)
            return allPages.filter { ($0.tags?.count ?? 0) > 0 }
            
        case .untagged:
            let descriptor = FetchDescriptor<Page>(
                sortBy: [SortDescriptor(\Page.modifiedAt, order: .reverse)]
            )
            let allPages = try modelContext.fetch(descriptor)
            return allPages.filter { ($0.tags?.count ?? 0) == 0 }
        }
    }
    
    func count(for collection: SmartCollection) throws -> Int {
        return try fetchPages(for: collection).count
    }
}
