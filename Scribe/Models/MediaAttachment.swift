// MediaAttachment.swift
// Scribe — SwiftData model for media attached to pages

import Foundation
import SwiftData

@Model
final class MediaAttachment {
    
    // MARK: - Properties
    
    var id: UUID
    var typeRaw: String
    var fileName: String
    
    /// Position on the canvas (encoded as x,y)
    var positionX: Double
    var positionY: Double
    
    /// Display size on canvas
    var displayWidth: Double
    var displayHeight: Double
    
    /// Rotation in radians
    var rotation: Double
    
    /// Z-ordering layer
    var zIndex: Int
    
    var createdAt: Date
    
    // MARK: - Relationships
    
    var page: Page?
    
    // MARK: - Computed
    
    var mediaType: MediaType {
        get { MediaType(rawValue: typeRaw) ?? .image }
        set { typeRaw = newValue.rawValue }
    }
    
    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set {
            positionX = newValue.x
            positionY = newValue.y
        }
    }
    
    var displaySize: CGSize {
        get { CGSize(width: displayWidth, height: displayHeight) }
        set {
            displayWidth = newValue.width
            displayHeight = newValue.height
        }
    }
    
    // MARK: - Init
    
    init(
        type: MediaType,
        fileName: String,
        position: CGPoint = .zero,
        displaySize: CGSize = CGSize(width: 200, height: 200)
    ) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.fileName = fileName
        self.positionX = position.x
        self.positionY = position.y
        self.displayWidth = displaySize.width
        self.displayHeight = displaySize.height
        self.rotation = 0
        self.zIndex = 0
        self.createdAt = Date()
    }
}
