// InfiniteCanvasManager.swift
// Scribe — Manages infinite canvas pan/zoom/tile logic

import UIKit

/// Manages the infinite canvas coordinate system and dynamic content size expansion
final class InfiniteCanvasManager {
    
    // MARK: - Properties
    
    /// Current canvas bounds in world coordinates
    private(set) var worldBounds: CGRect
    
    /// The expansion margin — when drawing approaches this distance from edge, expand canvas
    private let expansionMargin: CGFloat = 200
    
    /// How much to expand the canvas each time
    private let expansionChunk: CGFloat = 500
    
    /// Minimum canvas size
    private let minimumSize = CGSize(width: 768, height: 1024)
    
    /// Maximum canvas size to prevent runaway memory
    private let maximumSize = CGSize(width: 50000, height: 50000)
    
    // MARK: - Init
    
    init(initialSize: CGSize = CGSize(width: 768, height: 1024)) {
        self.worldBounds = CGRect(origin: .zero, size: initialSize)
    }
    
    // MARK: - Canvas Expansion
    
    /// Check if the canvas needs to expand based on the drawing bounds
    /// Returns the new content size if expansion occurred, nil otherwise
    func expandIfNeeded(drawingBounds: CGRect) -> CGSize? {
        var needsExpansion = false
        var newBounds = worldBounds
        
        // Check right edge
        if drawingBounds.maxX > worldBounds.maxX - expansionMargin {
            newBounds.size.width = min(
                drawingBounds.maxX + expansionChunk,
                maximumSize.width
            )
            needsExpansion = true
        }
        
        // Check bottom edge
        if drawingBounds.maxY > worldBounds.maxY - expansionMargin {
            newBounds.size.height = min(
                drawingBounds.maxY + expansionChunk,
                maximumSize.height
            )
            needsExpansion = true
        }
        
        // Check left edge (negative territory)
        if drawingBounds.minX < worldBounds.minX + expansionMargin {
            let shift = expansionChunk
            newBounds.origin.x -= shift
            newBounds.size.width += shift
            needsExpansion = true
        }
        
        // Check top edge (negative territory)
        if drawingBounds.minY < worldBounds.minY + expansionMargin {
            let shift = expansionChunk
            newBounds.origin.y -= shift
            newBounds.size.height += shift
            needsExpansion = true
        }
        
        if needsExpansion {
            worldBounds = newBounds
            return newBounds.size
        }
        
        return nil
    }
    
    /// Reset to fixed page size (for page mode)
    func setFixedSize(_ size: CGSize) {
        worldBounds = CGRect(origin: .zero, size: size)
    }
    
    /// Get the visible rect for a given viewport and zoom scale
    func visibleWorldRect(viewportSize: CGSize, contentOffset: CGPoint, zoomScale: CGFloat) -> CGRect {
        let scaledSize = CGSize(
            width: viewportSize.width / zoomScale,
            height: viewportSize.height / zoomScale
        )
        let origin = CGPoint(
            x: contentOffset.x / zoomScale,
            y: contentOffset.y / zoomScale
        )
        return CGRect(origin: origin, size: scaledSize)
    }
}
