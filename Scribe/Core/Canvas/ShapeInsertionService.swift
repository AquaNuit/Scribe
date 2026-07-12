// ShapeInsertionService.swift
// Scribe — Helper for injecting vector shapes into a PencilKit drawing

import UIKit
import PencilKit

enum ScribeShapeType: String, CaseIterable, Identifiable {
    case rectangle = "Rectangle"
    case circle = "Circle"
    case triangle = "Triangle"
    case line = "Line"
    case arrow = "Arrow"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        case .triangle: return "triangle"
        case .line: return "line.diagonal"
        case .arrow: return "arrow.up.right"
        }
    }
}

final class ShapeInsertionService {
    
    /// Generates a PKDrawing containing the specified shape.
    /// This drawing can be appended to an existing canvas drawing.
    static func createShapeDrawing(
        type: ScribeShapeType,
        color: UIColor,
        width: CGFloat,
        bounds: CGRect
    ) -> PKDrawing {
        
        let path = UIBezierPath()
        
        switch type {
        case .rectangle:
            path.append(UIBezierPath(rect: bounds))
        case .circle:
            path.append(UIBezierPath(ovalIn: bounds))
        case .triangle:
            path.move(to: CGPoint(x: bounds.midX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            path.close()
        case .line:
            path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        case .arrow:
            path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            
            // Arrow head
            let headSize: CGFloat = 20
            path.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX - headSize, y: bounds.minY))
            path.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY + headSize))
        }
        
        // Convert UIBezierPath to PKStroke (iOS 14+)
        var points: [PKStrokePoint] = []
        
        // This is a simplified conversion. For a true continuous stroke,
        // we interpolate points along the bezier path.
        // For standard straight-line shapes like rect/triangle, we can sample the path.
        // To keep it simple, we sample points along the CGPath.
        
        let cgPath = path.cgPath
        let transform = CGAffineTransform.identity
        
        // We'll create a single stroke if possible, or multiple strokes.
        // For a hacky but functional approach in iOS 14+, we can just create an ink
        let ink = PKInk(.pen, color: color)
        
        // Unfortunately, creating a perfect PKStrokePath from a UIBezierPath requires manual sampling.
        // Let's create a simplified set of strokes based on the shape type instead to ensure it works flawlessly.
        
        var strokes: [PKStroke] = []
        
        switch type {
        case .rectangle:
            strokes = createStraightStrokes(from: [
                CGPoint(x: bounds.minX, y: bounds.minY),
                CGPoint(x: bounds.maxX, y: bounds.minY),
                CGPoint(x: bounds.maxX, y: bounds.maxY),
                CGPoint(x: bounds.minX, y: bounds.maxY),
                CGPoint(x: bounds.minX, y: bounds.minY)
            ], ink: ink, width: width)
            
        case .triangle:
            strokes = createStraightStrokes(from: [
                CGPoint(x: bounds.midX, y: bounds.minY),
                CGPoint(x: bounds.maxX, y: bounds.maxY),
                CGPoint(x: bounds.minX, y: bounds.maxY),
                CGPoint(x: bounds.midX, y: bounds.minY)
            ], ink: ink, width: width)
            
        case .line:
            strokes = createStraightStrokes(from: [
                CGPoint(x: bounds.minX, y: bounds.minY),
                CGPoint(x: bounds.maxX, y: bounds.maxY)
            ], ink: ink, width: width)
            
        case .arrow:
            let p1 = CGPoint(x: bounds.minX, y: bounds.maxY)
            let p2 = CGPoint(x: bounds.maxX, y: bounds.minY)
            let headSize: CGFloat = 20
            strokes = createStraightStrokes(from: [p1, p2], ink: ink, width: width)
            strokes += createStraightStrokes(from: [
                CGPoint(x: bounds.maxX - headSize, y: bounds.minY),
                p2,
                CGPoint(x: bounds.maxX, y: bounds.minY + headSize)
            ], ink: ink, width: width)
            
        case .circle:
            strokes = createCircleStrokes(bounds: bounds, ink: ink, width: width)
        }
        
        return PKDrawing(strokes: strokes)
    }
    
    private static func createStraightStrokes(from points: [CGPoint], ink: PKInk, width: CGFloat) -> [PKStroke] {
        var pkPoints: [PKStrokePoint] = []
        
        // Add multiple interpolated points to make a valid stroke
        for i in 0..<(points.count - 1) {
            let start = points[i]
            let end = points[i+1]
            
            let steps = 20
            for step in 0...steps {
                let t = CGFloat(step) / CGFloat(steps)
                let x = start.x + (end.x - start.x) * t
                let y = start.y + (end.y - start.y) * t
                let point = CGPoint(x: x, y: y)
                
                let pkPoint = PKStrokePoint(
                    location: point,
                    timeOffset: TimeInterval(step) * 0.01,
                    size: CGSize(width: width, height: width),
                    opacity: 1.0,
                    force: 1.0,
                    azimuth: 0,
                    altitude: 0
                )
                pkPoints.append(pkPoint)
            }
        }
        
        let path = PKStrokePath(controlPoints: pkPoints, creationDate: Date())
        let stroke = PKStroke(ink: ink, path: path)
        return [stroke]
    }
    
    private static func createCircleStrokes(bounds: CGRect, ink: PKInk, width: CGFloat) -> [PKStroke] {
        var pkPoints: [PKStrokePoint] = []
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        
        let steps = 60
        for step in 0...steps {
            let angle = (CGFloat(step) / CGFloat(steps)) * 2 * .pi
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            
            let pkPoint = PKStrokePoint(
                location: point,
                timeOffset: TimeInterval(step) * 0.01,
                size: CGSize(width: width, height: width),
                opacity: 1.0,
                force: 1.0,
                azimuth: 0,
                altitude: 0
            )
            pkPoints.append(pkPoint)
        }
        
        let path = PKStrokePath(controlPoints: pkPoints, creationDate: Date())
        let stroke = PKStroke(ink: ink, path: path)
        return [stroke]
    }
}
