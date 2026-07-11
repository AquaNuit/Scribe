// SectionService.swift
// Scribe — Business logic for section management within notebooks

import Foundation
import SwiftData

@MainActor
final class SectionService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Create
    
    @discardableResult
    func createSection(
        in notebook: Notebook,
        title: String,
        colorHex: String? = nil
    ) -> Section {
        let section = Section(
            title: title,
            sortOrder: notebook.sortedSections.count,
            colorHex: colorHex
        )
        section.notebook = notebook
        
        var sections = notebook.sections ?? []
        sections.append(section)
        notebook.sections = sections
        
        notebook.touch()
        try? modelContext.save()
        
        return section
    }
    
    // MARK: - Update
    
    func updateTitle(_ section: Section, title: String) {
        section.title = title
        section.touch()
        section.notebook?.touch()
        try? modelContext.save()
    }
    
    func updateColor(_ section: Section, colorHex: String?) {
        section.colorHex = colorHex
        section.touch()
        try? modelContext.save()
    }
    
    func reorderSections(in notebook: Notebook, fromOffsets: IndexSet, toOffset: Int) {
        var sections = notebook.sortedSections
        sections.move(fromOffsets: fromOffsets, toOffset: toOffset)
        
        for (index, section) in sections.enumerated() {
            section.sortOrder = index
        }
        
        notebook.touch()
        try? modelContext.save()
    }
    
    // MARK: - Move
    
    func moveSection(_ section: Section, to notebook: Notebook) {
        // Remove from old notebook
        if let oldNotebook = section.notebook {
            oldNotebook.sections?.removeAll { $0.id == section.id }
            oldNotebook.touch()
        }
        
        // Add to new notebook
        section.notebook = notebook
        section.sortOrder = notebook.sortedSections.count
        
        var sections = notebook.sections ?? []
        sections.append(section)
        notebook.sections = sections
        
        notebook.touch()
        try? modelContext.save()
    }
    
    // MARK: - Merge
    
    func mergeSections(_ source: Section, into target: Section) {
        let pages = source.sortedPages
        let offset = target.sortedPages.count
        
        for (index, page) in pages.enumerated() {
            page.section = target
            page.sortOrder = offset + index
        }
        
        var targetPages = target.pages ?? []
        targetPages.append(contentsOf: pages)
        target.pages = targetPages
        
        source.pages = []
        
        target.touch()
        target.notebook?.touch()
        
        // Delete the now-empty source section
        modelContext.delete(source)
        try? modelContext.save()
    }
    
    // MARK: - Delete
    
    func deleteSection(_ section: Section) {
        section.notebook?.touch()
        modelContext.delete(section)
        try? modelContext.save()
    }
}
