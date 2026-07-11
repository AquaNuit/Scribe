// BackupService.swift
// Scribe — Export and import notebook backups

import Foundation
import SwiftData
import OSLog
import UniformTypeIdentifiers

/// Manages backup and restore of notebooks
@MainActor
final class BackupService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Export
    
    struct NotebookBackup: Codable {
        let version: Int
        let exportDate: Date
        let notebook: NotebookData
        
        struct NotebookData: Codable {
            let title: String
            let coverColorHex: String
            let emoji: String?
            let sections: [SectionData]
        }
        
        struct SectionData: Codable {
            let title: String
            let sortOrder: Int
            let pages: [PageData]
        }
        
        struct PageData: Codable {
            let title: String
            let backgroundStyle: String
            let canvasMode: String
            let canvasWidth: Double
            let canvasHeight: Double
            let sortOrder: Int
            let drawingData: Data?
        }
    }
    
    /// Export a notebook to a backup file
    func exportNotebook(_ notebook: Notebook) throws -> Data {
        Logger.storage.info("Exporting notebook: \(notebook.title)")
        
        let sections = notebook.sortedSections.map { section in
            NotebookBackup.SectionData(
                title: section.title,
                sortOrder: section.sortOrder,
                pages: section.sortedPages.map { page in
                    NotebookBackup.PageData(
                        title: page.title,
                        backgroundStyle: page.backgroundStyleRaw,
                        canvasMode: page.canvasModeRaw,
                        canvasWidth: page.canvasWidth,
                        canvasHeight: page.canvasHeight,
                        sortOrder: page.sortOrder,
                        drawingData: page.drawingData
                    )
                }
            )
        }
        
        let backup = NotebookBackup(
            version: 1,
            exportDate: Date(),
            notebook: NotebookBackup.NotebookData(
                title: notebook.title,
                coverColorHex: notebook.coverColorHex,
                emoji: notebook.emoji,
                sections: sections
            )
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(backup)
    }
    
    // MARK: - Import
    
    /// Import a notebook from backup data
    @discardableResult
    func importNotebook(from data: Data) throws -> Notebook {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backup = try decoder.decode(NotebookBackup.self, from: data)
        
        Logger.storage.info("Importing notebook: \(backup.notebook.title)")
        
        let notebook = Notebook(
            title: backup.notebook.title,
            coverColor: backup.notebook.coverColorHex,
            emoji: backup.notebook.emoji
        )
        
        var sections: [Section] = []
        
        for sectionData in backup.notebook.sections {
            let section = Section(title: sectionData.title, sortOrder: sectionData.sortOrder)
            section.notebook = notebook
            
            var pages: [Page] = []
            
            for pageData in sectionData.pages {
                let page = Page(
                    title: pageData.title,
                    backgroundStyle: BackgroundStyle(rawValue: pageData.backgroundStyle) ?? .blank,
                    canvasMode: CanvasMode(rawValue: pageData.canvasMode) ?? .page
                )
                page.canvasWidth = pageData.canvasWidth
                page.canvasHeight = pageData.canvasHeight
                page.sortOrder = pageData.sortOrder
                page.drawingData = pageData.drawingData
                page.section = section
                pages.append(page)
            }
            
            section.pages = pages
            sections.append(section)
        }
        
        notebook.sections = sections
        modelContext.insert(notebook)
        try modelContext.save()
        
        Logger.storage.info("Successfully imported notebook with \(sections.count) sections")
        
        return notebook
    }
    
    /// File UTType for Scribe backup files
    static let backupUTType = UTType(exportedAs: "com.scribe.backup", conformingTo: .json)
}
