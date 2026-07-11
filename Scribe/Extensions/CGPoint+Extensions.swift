// CGPoint+Extensions.swift
// Scribe — Geometry utilities for canvas calculations

import CoreGraphics
import Foundation

extension CGPoint {
    
    /// Distance to another point
    func distance(to other: CGPoint) -> CGFloat {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Midpoint between two points
    func midpoint(to other: CGPoint) -> CGPoint {
        CGPoint(x: (x + other.x) / 2, y: (y + other.y) / 2)
    }
    
    /// Angle to another point in radians
    func angle(to other: CGPoint) -> CGFloat {
        atan2(other.y - y, other.x - x)
    }
    
    /// Point translated by dx, dy
    func translated(dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }
    
    /// Point scaled by factor from origin
    func scaled(by factor: CGFloat) -> CGPoint {
        CGPoint(x: x * factor, y: y * factor)
    }
    
    /// Linear interpolation between two points
    func lerp(to other: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(
            x: x + (other.x - x) * t,
            y: y + (other.y - y) * t
        )
    }
    
    /// Clamp point within a rectangle
    func clamped(to rect: CGRect) -> CGPoint {
        CGPoint(
            x: max(rect.minX, min(rect.maxX, x)),
            y: max(rect.minY, min(rect.maxY, y))
        )
    }
}

extension CGSize {
    
    /// Scale both dimensions by a factor
    func scaled(by factor: CGFloat) -> CGSize {
        CGSize(width: width * factor, height: height * factor)
    }
    
    /// Aspect ratio (width / height)
    var aspectRatio: CGFloat {
        guard height > 0 else { return 1 }
        return width / height
    }
}

extension CGRect {
    
    /// Center point of the rectangle
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    /// Expand rectangle by insets
    func expanded(by amount: CGFloat) -> CGRect {
        insetBy(dx: -amount, dy: -amount)
    }
}
