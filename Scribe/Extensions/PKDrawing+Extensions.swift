// PKDrawing+Extensions.swift
// Scribe — PencilKit drawing extensions

import PencilKit
import UIKit

extension PKDrawing {
    
    /// Get the total number of strokes
    var strokeCount: Int {
        strokes.count
    }
    
    /// Check if the drawing is empty (no strokes)
    var isEmpty: Bool {
        strokes.isEmpty
    }
    
    /// Generate a thumbnail image at the specified size
    func thumbnail(size: CGSize, scale: CGFloat = 2.0) -> UIImage {
        let drawingBounds = bounds
        
        guard !drawingBounds.isEmpty else {
            // Return blank image for empty drawings
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { _ in }
        }
        
        let aspectRatio = drawingBounds.width / drawingBounds.height
        let targetAspectRatio = size.width / size.height
        
        var renderRect: CGRect
        if aspectRatio > targetAspectRatio {
            // Drawing is wider — fit to width
            let height = size.width / aspectRatio
            renderRect = CGRect(x: 0, y: (size.height - height) / 2, width: size.width, height: height)
        } else {
            // Drawing is taller — fit to height
            let width = size.height * aspectRatio
            renderRect = CGRect(x: (size.width - width) / 2, y: 0, width: width, height: size.height)
        }
        
        return image(from: drawingBounds, scale: renderRect.width / drawingBounds.width * scale)
    }
    
    /// Merge another drawing into this one
    func merged(with other: PKDrawing) -> PKDrawing {
        var combined = self
        combined.append(other)
        return combined
    }
    
    /// Get the data size in bytes
    var dataSize: Int {
        dataRepresentation().count
    }
}
