// PDFImportService.swift
// Scribe — PDF import and page extraction

import Foundation
import PDFKit
import SwiftData
import OSLog

@MainActor
final class PDFImportService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Import a PDF document into a new notebook
    func importPDF(
        from url: URL,
        notebookTitle: String? = nil
    ) async throws -> Notebook {
        Logger.pdf.info("Importing PDF from: \(url.lastPathComponent)")
        
        // Access security-scoped resource
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }
        
        guard let pdfDocument = PDFDocument(url: url) else {
            throw PDFImportError.invalidDocument
        }
        
        let title = notebookTitle ?? url.deletingPathExtension().lastPathComponent
        let pageCount = pdfDocument.pageCount
        
        Logger.pdf.info("PDF has \(pageCount) pages")
        
        // Create notebook
        let notebook = Notebook(title: title, coverColor: "#E74C3C", emoji: "📄")
        let section = Section(title: "PDF Pages", sortOrder: 0)
        section.notebook = notebook
        
        var pages: [Page] = []
        
        // Create a page for each PDF page
        for i in 0..<pageCount {
            guard let pdfPage = pdfDocument.page(at: i) else { continue }
            
            let pageBounds = pdfPage.bounds(for: .mediaBox)
            let page = Page(title: "Page \(i + 1)", backgroundStyle: .blank)
            page.canvasWidth = pageBounds.width
            page.canvasHeight = pageBounds.height
            page.isPDFPage = true
            page.pdfPageIndex = i
            page.sortOrder = i
            page.section = section
            
            // Store PDF page data
            if let pageData = pdfDocument.page(at: i)?.dataRepresentation {
                page.pdfPageData = pageData
            }
            
            pages.append(page)
        }
        
        section.pages = pages
        notebook.sections = [section]
        
        modelContext.insert(notebook)
        try modelContext.save()
        
        Logger.pdf.info("Successfully imported PDF with \(pageCount) pages")
        
        return notebook
    }
    
    /// Import a PDF as annotation overlay on existing pages
    func importPDFForAnnotation(from url: URL) throws -> PDFDocument? {
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }
        
        return PDFDocument(url: url)
    }
}

// MARK: - Errors

enum PDFImportError: LocalizedError {
    case invalidDocument
    case pageExtractionFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidDocument: return "Unable to open the PDF document"
        case .pageExtractionFailed: return "Failed to extract PDF pages"
        case .saveFailed: return "Failed to save imported PDF"
        }
    }
}
