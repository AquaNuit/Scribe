// TagService.swift
// Scribe — Business logic for the tagging system

import Foundation
import SwiftData

@MainActor
final class TagService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Create
    
    @discardableResult
    func createTag(name: String, colorHex: String = "#FF6B6B") -> Tag {
        let tag = Tag(name: name, colorHex: colorHex)
        modelContext.insert(tag)
        try? modelContext.save()
        return tag
    }
    
    // MARK: - Read
    
    func fetchAllTags() throws -> [Tag] {
        let descriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\Tag.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func findOrCreateTag(name: String, colorHex: String = "#FF6B6B") throws -> Tag {
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.name == name }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        
        return createTag(name: name, colorHex: colorHex)
    }
    
    // MARK: - Assign / Remove
    
    func addTag(_ tag: Tag, to page: Page) {
        var pageTags = page.tags ?? []
        guard !pageTags.contains(where: { $0.id == tag.id }) else { return }
        pageTags.append(tag)
        page.tags = pageTags
        
        var tagPages = tag.pages ?? []
        tagPages.append(page)
        tag.pages = tagPages
        
        page.touch()
        try? modelContext.save()
    }
    
    func removeTag(_ tag: Tag, from page: Page) {
        page.tags?.removeAll { $0.id == tag.id }
        tag.pages?.removeAll { $0.id == page.id }
        
        page.touch()
        try? modelContext.save()
    }
    
    func toggleTag(_ tag: Tag, on page: Page) {
        let hasTags = page.tags?.contains(where: { $0.id == tag.id }) ?? false
        if hasTags {
            removeTag(tag, from: page)
        } else {
            addTag(tag, to: page)
        }
    }
    
    // MARK: - Query
    
    func pagesWithTag(_ tag: Tag) -> [Page] {
        return tag.pages ?? []
    }
    
    func tagsForPage(_ page: Page) -> [Tag] {
        return page.tags ?? []
    }
    
    // MARK: - Update
    
    func updateTag(_ tag: Tag, name: String? = nil, colorHex: String? = nil) {
        if let name = name { tag.name = name }
        if let colorHex = colorHex { tag.colorHex = colorHex }
        try? modelContext.save()
    }
    
    // MARK: - Delete
    
    func deleteTag(_ tag: Tag) {
        // Remove from all pages first
        for page in tag.pages ?? [] {
            page.tags?.removeAll { $0.id == tag.id }
        }
        modelContext.delete(tag)
        try? modelContext.save()
    }
}
