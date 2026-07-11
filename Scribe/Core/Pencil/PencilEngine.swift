// PencilEngine.swift
// Scribe — Apple Pencil input processing and pressure curve management

import UIKit
import PencilKit

/// Processes Apple Pencil input with pressure curves and stroke smoothing
final class PencilEngine {
    
    // MARK: - Pressure Curve
    
    struct PressureCurve {
        /// Minimum width multiplier at zero pressure
        var minWidthFactor: CGFloat = 0.3
        
        /// Maximum width multiplier at full pressure
        var maxWidthFactor: CGFloat = 1.5
        
        /// Curve exponent — <1 makes it easier to get thick lines, >1 harder
        var gamma: CGFloat = 0.7
        
        /// Sensitivity multiplier (0.0 to 2.0)
        var sensitivity: CGFloat = 1.0
        
        func apply(pressure: CGFloat) -> CGFloat {
            let clampedPressure = max(0, min(1, pressure * sensitivity))
            let curved = pow(clampedPressure, gamma)
            return minWidthFactor + (maxWidthFactor - minWidthFactor) * curved
        }
    }
    
    // MARK: - Properties
    
    var pressureCurve = PressureCurve()
    
    /// Whether hover preview is enabled
    var hoverEnabled: Bool = true
    
    /// Current hover position (nil when not hovering)
    var hoverPosition: CGPoint?
    
    /// Current hover altitude angle
    var hoverAltitude: CGFloat?
    
    // MARK: - Pressure Processing
    
    /// Calculate the stroke width for a given pressure and base width
    func strokeWidth(forPressure pressure: CGFloat, baseWidth: CGFloat) -> CGFloat {
        return baseWidth * pressureCurve.apply(pressure: pressure)
    }
    
    /// Calculate tilt-based shading opacity
    func tiltOpacity(altitude: CGFloat) -> CGFloat {
        // altitude: 0 (flat) to π/2 (perpendicular)
        let normalizedTilt = altitude / (.pi / 2)
        // More flat = more shading effect
        return 0.3 + 0.7 * normalizedTilt
    }
    
    /// Calculate tilt-based width expansion (for pencil shading)
    func tiltWidthMultiplier(altitude: CGFloat) -> CGFloat {
        let normalizedTilt = altitude / (.pi / 2)
        // More flat = wider stroke
        return 1.0 + (1.0 - normalizedTilt) * 3.0
    }
    
    
}

extension PencilEngine.PressureCurve {
    static let linear = PencilEngine.PressureCurve(minWidthFactor: 0.5, maxWidthFactor: 1.5, gamma: 1.0, sensitivity: 1.0)
    static let soft = PencilEngine.PressureCurve(minWidthFactor: 0.4, maxWidthFactor: 1.3, gamma: 0.5, sensitivity: 1.2)
    static let firm = PencilEngine.PressureCurve(minWidthFactor: 0.2, maxWidthFactor: 1.8, gamma: 1.5, sensitivity: 0.8)
    static let calligraphy = PencilEngine.PressureCurve(minWidthFactor: 0.1, maxWidthFactor: 2.0, gamma: 0.6, sensitivity: 1.0)
}
