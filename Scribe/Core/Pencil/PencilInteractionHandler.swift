// PencilInteractionHandler.swift
// Scribe — Handles Apple Pencil Pro interactions (hover, squeeze, barrel roll)

import UIKit
import PencilKit

/// Manages Apple Pencil interaction events on the canvas
final class PencilInteractionHandler: NSObject {
    
    // MARK: - Properties
    
    weak var toolState: ToolState?
    
    /// Current hover position (nil when not hovering)
    var hoverPosition: CGPoint?
    
    /// Current hover altitude
    var hoverAltitude: CGFloat?
    
    /// Current hover azimuth
    var hoverAzimuth: CGFloat?
    
    /// Callback for hover position changes
    var onHoverChanged: ((CGPoint?, CGFloat?) -> Void)?
    
    /// Callback for squeeze action
    var onSqueeze: (() -> Void)?
    
    // MARK: - Squeeze Handling
    
    /// Called when Apple Pencil Pro is squeezed
    func handleSqueeze() {
        toolState?.toggleEraser()
        onSqueeze?()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Hover Handling
    
    func handleHoverBegan(at position: CGPoint, altitude: CGFloat, azimuth: CGFloat) {
        hoverPosition = position
        hoverAltitude = altitude
        hoverAzimuth = azimuth
        onHoverChanged?(position, altitude)
    }
    
    func handleHoverMoved(to position: CGPoint, altitude: CGFloat, azimuth: CGFloat) {
        hoverPosition = position
        hoverAltitude = altitude
        hoverAzimuth = azimuth
        onHoverChanged?(position, altitude)
    }
    
    func handleHoverEnded() {
        hoverPosition = nil
        hoverAltitude = nil
        hoverAzimuth = nil
        onHoverChanged?(nil, nil)
    }
}
