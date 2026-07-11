// Page.swift
// Scribe — SwiftData model for individual pages

import Foundation
import SwiftData
import PencilKit

@Model
final class Page {
    
    // MARK: - Properties
    
    var id: UUID
    var title: String
    
    /// Serialized PKDrawing data — the actual handwritten content
    var drawingData: Data?
    
    /// JPEG thumbnail for fast list display (generated async)
    var thumbnailData: Data?
    
    /// Canvas background style encoded as string
    var backgroundStyleRaw: String
    
    /// "page" or "whiteboard"
    var canvasModeRaw: String
    
    /// Canvas dimensions in points
    var canvasWidth: Double
    var canvasHeight: Double
    
    /// Ordering within the section
    var sortOrder: Int
    
    /// Timestamps
    var createdAt: Date
    var modifiedAt: Date
    
    /// Whether this page is sourced from a PDF
    var isPDFPage: Bool
    
    /// Original PDF data (if imported from PDF)
    var pdfPageData: Data?
    
    /// PDF page index (if part of an imported PDF)
    var pdfPageIndex: Int?
    
    // MARK: - Relationships
    
    var section: Section?
    
    @Relationship(deleteRule: .cascade, inverse: \MediaAttachment.page)
    var mediaAttachments: [MediaAttachment]?
    
    var tags: [Tag]?
    
    // MARK: - Computed Properties
    
    var backgroundStyle: BackgroundStyle {
        get { BackgroundStyle(rawValue: backgroundStyleRaw) ?? .blank }
        set { backgroundStyleRaw = newValue.rawValue }
    }
    
    var canvasMode: CanvasMode {
        get { CanvasMode(rawValue: canvasModeRaw) ?? .page }
        set { canvasModeRaw = newValue.rawValue }
    }
    
    var canvasSize: CGSize {
        get { CGSize(width: canvasWidth, height: canvasHeight) }
        set {
            canvasWidth = newValue.width
            canvasHeight = newValue.height
        }
    }
    
    /// Decode PKDrawing from stored data
    var drawing: PKDrawing? {
        get {
            guard let data = drawingData else { return nil }
            return try? PKDrawing(data: data)
        }
        set {
            drawingData = newValue?.dataRepresentation()
            touch()
        }
    }
    
    // MARK: - Init
    
    init(
        title: String = "",
        backgroundStyle: BackgroundStyle = .blank,
        canvasMode: CanvasMode = .page
    ) {
        self.id = UUID()
        self.title = title
        self.backgroundStyleRaw = backgroundStyle.rawValue
        self.canvasModeRaw = canvasMode.rawValue
        self.canvasWidth = 768
        self.canvasHeight = 1024
        self.sortOrder = 0
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isPDFPage = false
    }
    
    // MARK: - Methods
    
    func touch() {
        self.modifiedAt = Date()
    }
    
    /// Generate a thumbnail image from the current drawing
    func generateThumbnail(size: CGSize = CGSize(width: 200, height: 260)) {
        guard let drawing = self.drawing else {
            self.thumbnailData = nil
            return
        }
        
        let image = drawing.image(
            from: CGRect(origin: .zero, size: canvasSize),
            scale: size.width / canvasWidth
        )
        self.thumbnailData = image.jpegData(compressionQuality: 0.6)
    }
}
