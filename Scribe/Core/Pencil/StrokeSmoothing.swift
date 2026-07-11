// StrokeSmoothing.swift
// Scribe — Catmull-Rom stroke interpolation and smoothing

import CoreGraphics

/// Provides stroke smoothing using Catmull-Rom spline interpolation
struct StrokeSmoothing {
    
    /// Smoothing intensity (0.0 = none, 1.0 = maximum)
    var intensity: CGFloat = 0.5
    
    /// Number of interpolation segments between control points
    var segmentsPerCurve: Int = 8
    
    // MARK: - Catmull-Rom Interpolation
    
    /// Smooth a sequence of points using Catmull-Rom spline interpolation
    func smooth(points: [CGPoint]) -> [CGPoint] {
        guard points.count >= 4 else { return points }
        
        var result: [CGPoint] = [points[0]]
        
        for i in 1..<(points.count - 2) {
            let p0 = points[i - 1]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = points[i + 2]
            
            for j in 0..<segmentsPerCurve {
                let t = CGFloat(j) / CGFloat(segmentsPerCurve)
                let point = catmullRom(p0: p0, p1: p1, p2: p2, p3: p3, t: t)
                
                // Blend between raw and smoothed based on intensity
                let rawPoint = p1
                let blended = CGPoint(
                    x: rawPoint.x + (point.x - rawPoint.x) * intensity,
                    y: rawPoint.y + (point.y - rawPoint.y) * intensity
                )
                result.append(blended)
            }
        }
        
        result.append(points.last!)
        return result
    }
    
    /// Catmull-Rom spline interpolation between four points
    private func catmullRom(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint, t: CGFloat) -> CGPoint {
        let t2 = t * t
        let t3 = t2 * t
        
        let x = 0.5 * (
            (2 * p1.x) +
            (-p0.x + p2.x) * t +
            (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 +
            (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3
        )
        
        let y = 0.5 * (
            (2 * p1.y) +
            (-p0.y + p2.y) * t +
            (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 +
            (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3
        )
        
        return CGPoint(x: x, y: y)
    }
    
    // MARK: - Douglas-Peucker Simplification
    
    /// Simplify a path by removing redundant points
    func simplify(points: [CGPoint], tolerance: CGFloat = 1.0) -> [CGPoint] {
        guard points.count > 2 else { return points }
        return douglasPeucker(points: points, epsilon: tolerance)
    }
    
    private func douglasPeucker(points: [CGPoint], epsilon: CGFloat) -> [CGPoint] {
        guard points.count > 2 else { return points }
        
        var maxDistance: CGFloat = 0
        var maxIndex = 0
        
        let start = points.first!
        let end = points.last!
        
        for i in 1..<(points.count - 1) {
            let distance = perpendicularDistance(point: points[i], lineStart: start, lineEnd: end)
            if distance > maxDistance {
                maxDistance = distance
                maxIndex = i
            }
        }
        
        if maxDistance > epsilon {
            let left = douglasPeucker(points: Array(points[0...maxIndex]), epsilon: epsilon)
            let right = douglasPeucker(points: Array(points[maxIndex...]), epsilon: epsilon)
            return Array(left.dropLast()) + right
        } else {
            return [start, end]
        }
    }
    
    private func perpendicularDistance(point: CGPoint, lineStart: CGPoint, lineEnd: CGPoint) -> CGFloat {
        let dx = lineEnd.x - lineStart.x
        let dy = lineEnd.y - lineStart.y
        
        let length = sqrt(dx * dx + dy * dy)
        guard length > 0 else { return 0 }
        
        return abs(dy * point.x - dx * point.y + lineEnd.x * lineStart.y - lineEnd.y * lineStart.x) / length
    }
}
