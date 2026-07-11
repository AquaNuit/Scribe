// NotebookService.swift
// Scribe — Business logic for notebook management

import Foundation
import SwiftData

/// Handles all notebook CRUD operations
@MainActor
final class NotebookService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Create
    
    @discardableResult
    func createNotebook(
        title: String,
        coverColor: String = "#5B7FFF",
        emoji: String? = "📓",
        template: Template = .blank
    ) -> Notebook {
        let notebook = Notebook(title: title, coverColor: coverColor, emoji: emoji)
        
        // Create a default section with one page
        let section = Section(title: "Section 1", sortOrder: 0)
        let page = Page(
            title: "",
            backgroundStyle: template.backgroundStyle,
            canvasMode: .page
        )
        
        section.pages = [page]
        notebook.sections = [section]
        section.notebook = notebook
        page.section = section
        
        modelContext.insert(notebook)
        
        try? modelContext.save()
        
        return notebook
    }
    
    // MARK: - Read
    
    func fetchAllNotebooks(
        sortBy: NotebookSortOrder = .dateModified,
        includeArchived: Bool = false
    ) throws -> [Notebook] {
        var descriptor = FetchDescriptor<Notebook>()
        
        if !includeArchived {
            descriptor.predicate = #Predicate { !$0.isArchived }
        }
        
        switch sortBy {
        case .dateModified:
            descriptor.sortBy = [SortDescriptor(\Notebook.modifiedAt, order: .reverse)]
        case .dateCreated:
            descriptor.sortBy = [SortDescriptor(\Notebook.createdAt, order: .reverse)]
        case .title:
            descriptor.sortBy = [SortDescriptor(\Notebook.title)]
        case .manual:
            descriptor.sortBy = [SortDescriptor(\Notebook.sortOrder)]
        }
        
        return try modelContext.fetch(descriptor)
    }
    
    func fetchFavorites() throws -> [Notebook] {
        let descriptor = FetchDescriptor<Notebook>(
            predicate: #Predicate { $0.isFavorite && !$0.isArchived },
            sortBy: [SortDescriptor(\Notebook.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchArchived() throws -> [Notebook] {
        let descriptor = FetchDescriptor<Notebook>(
            predicate: #Predicate { $0.isArchived },
            sortBy: [SortDescriptor(\Notebook.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Update
    
    func updateNotebook(_ notebook: Notebook, title: String? = nil, coverColor: String? = nil, emoji: String? = nil) {
        if let title = title { notebook.title = title }
        if let coverColor = coverColor { notebook.coverColorHex = coverColor }
        if let emoji = emoji { notebook.emoji = emoji }
        notebook.touch()
        try? modelContext.save()
    }
    
    func toggleFavorite(_ notebook: Notebook) {
        notebook.isFavorite.toggle()
        notebook.touch()
        try? modelContext.save()
    }
    
    func archiveNotebook(_ notebook: Notebook) {
        notebook.isArchived = true
        notebook.touch()
        try? modelContext.save()
    }
    
    func unarchiveNotebook(_ notebook: Notebook) {
        notebook.isArchived = false
        notebook.touch()
        try? modelContext.save()
    }
    
    // MARK: - Delete
    
    func deleteNotebook(_ notebook: Notebook) {
        modelContext.delete(notebook)
        try? modelContext.save()
    }
    
    // MARK: - Search
    
    func searchNotebooks(query: String) throws -> [Notebook] {
        let descriptor = FetchDescriptor<Notebook>(
            predicate: #Predicate { notebook in
                notebook.title.localizedStandardContains(query) && !notebook.isArchived
            },
            sortBy: [SortDescriptor(\Notebook.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
