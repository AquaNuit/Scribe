// PageService.swift
// Scribe — Business logic for page management

import Foundation
import SwiftData
import PencilKit

@MainActor
final class PageService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Create
    
    @discardableResult
    func createPage(
        in section: Section,
        title: String = "",
        backgroundStyle: BackgroundStyle = .blank,
        canvasMode: CanvasMode = .page,
        atIndex: Int? = nil
    ) -> Page {
        let page = Page(
            title: title,
            backgroundStyle: backgroundStyle,
            canvasMode: canvasMode
        )
        
        let existingPages = section.pages ?? []
        page.sortOrder = atIndex ?? existingPages.count
        page.section = section
        
        var pages = existingPages
        pages.append(page)
        section.pages = pages
        
        section.touch()
        section.notebook?.touch()
        
        try? modelContext.save()
        
        return page
    }
    
    // MARK: - Read
    
    func fetchPages(in section: Section) -> [Page] {
        return section.sortedPages
    }
    
    // MARK: - Update
    
    func updateDrawing(_ page: Page, drawing: PKDrawing) {
        page.drawing = drawing
        page.generateThumbnail()
        page.touch()
        page.section?.notebook?.touch()
        try? modelContext.save()
    }
    
    func updateTitle(_ page: Page, title: String) {
        page.title = title
        page.touch()
        try? modelContext.save()
    }
    
    func updateBackground(_ page: Page, style: BackgroundStyle) {
        page.backgroundStyle = style
        page.touch()
        try? modelContext.save()
    }
    
    func updateCanvasMode(_ page: Page, mode: CanvasMode) {
        page.canvasMode = mode
        page.touch()
        try? modelContext.save()
    }
    
    func updateAppearance(_ page: Page, appearance: CanvasAppearance) {
        page.canvasAppearance = appearance
        page.touch()
        try? modelContext.save()
    }
    
    func reorderPages(in section: Section, fromOffsets: IndexSet, toOffset: Int) {
        var pages = section.sortedPages
        pages.move(fromOffsets: fromOffsets, toOffset: toOffset)
        
        for (index, page) in pages.enumerated() {
            page.sortOrder = index
        }
        
        try? modelContext.save()
    }
    
    // MARK: - Move
    
    func movePage(_ page: Page, to section: Section) {
        page.section = section
        page.sortOrder = (section.pages?.count ?? 0)
        page.touch()
        section.touch()
        section.notebook?.touch()
        try? modelContext.save()
    }
    
    // MARK: - Duplicate
    
    @discardableResult
    func duplicatePage(_ page: Page) -> Page? {
        guard let section = page.section else { return nil }
        
        let newPage = Page(
            title: "\(page.title) (Copy)",
            backgroundStyle: page.backgroundStyle,
            canvasMode: page.canvasMode
        )
        newPage.drawingData = page.drawingData
        newPage.thumbnailData = page.thumbnailData
        newPage.canvasWidth = page.canvasWidth
        newPage.canvasHeight = page.canvasHeight
        newPage.sortOrder = page.sortOrder + 1
        newPage.section = section
        
        // Shift subsequent pages
        let pages = section.sortedPages
        for p in pages where p.sortOrder >= newPage.sortOrder && p.id != newPage.id {
            p.sortOrder += 1
        }
        
        var sectionPages = section.pages ?? []
        sectionPages.append(newPage)
        section.pages = sectionPages
        
        try? modelContext.save()
        
        return newPage
    }
    
    // MARK: - Delete
    
    func deletePage(_ page: Page) {
        modelContext.delete(page)
        try? modelContext.save()
    }
}
