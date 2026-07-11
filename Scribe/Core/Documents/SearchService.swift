// SearchService.swift
// Scribe — Full-text search across notebooks, sections, pages, and tags

import Foundation
import SwiftData
import OSLog

@MainActor
final class SearchService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Unified Search
    
    struct SearchResults {
        var notebooks: [Notebook] = []
        var pages: [Page] = []
        var tags: [Tag] = []
        
        var totalCount: Int { notebooks.count + pages.count + tags.count }
        var isEmpty: Bool { totalCount == 0 }
    }
    
    func search(query: String) throws -> SearchResults {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return SearchResults() }
        
        Logger.search.info("Searching for: \(trimmed)")
        
        var results = SearchResults()
        
        // Search notebooks
        let notebookDescriptor = FetchDescriptor<Notebook>(
            predicate: #Predicate<Notebook> { notebook in
                notebook.title.localizedStandardContains(trimmed) && !notebook.isArchived
            },
            sortBy: [SortDescriptor(\Notebook.modifiedAt, order: .reverse)]
        )
        results.notebooks = try modelContext.fetch(notebookDescriptor)
        
        // Search pages by title
        let pageDescriptor = FetchDescriptor<Page>(
            predicate: #Predicate<Page> { page in
                page.title.localizedStandardContains(trimmed)
            },
            sortBy: [SortDescriptor(\Page.modifiedAt, order: .reverse)]
        )
        results.pages = try modelContext.fetch(pageDescriptor)
        
        // Search tags
        let tagDescriptor = FetchDescriptor<Tag>(
            predicate: #Predicate<Tag> { tag in
                tag.name.localizedStandardContains(trimmed)
            },
            sortBy: [SortDescriptor(\Tag.name)]
        )
        results.tags = try modelContext.fetch(tagDescriptor)
        
        Logger.search.info("Found \(results.totalCount) results")
        
        return results
    }
    
    // MARK: - Recent Pages
    
    func recentPages(limit: Int = 20) throws -> [Page] {
        var descriptor = FetchDescriptor<Page>(
            sortBy: [SortDescriptor(\Page.modifiedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Pages by Background Style
    
    func pages(withBackground style: BackgroundStyle) throws -> [Page] {
        let raw = style.rawValue
        let descriptor = FetchDescriptor<Page>(
            predicate: #Predicate<Page> { $0.backgroundStyleRaw == raw },
            sortBy: [SortDescriptor(\Page.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
