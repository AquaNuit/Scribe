// ToolType.swift
// Scribe — Drawing tool type enumeration

import Foundation
import PencilKit

/// Available drawing tools
enum ToolType: String, Codable, CaseIterable, Identifiable {
    case fountainPen = "fountainPen"
    case pencil = "pencil"
    case marker = "marker"
    case highlighter = "highlighter"
    case brush = "brush"
    case calligraphy = "calligraphy"
    case eraserPixel = "eraserPixel"
    case eraserStroke = "eraserStroke"
    case lasso = "lasso"
    case ruler = "ruler"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .fountainPen: return "Pen"
        case .pencil: return "Pencil"
        case .marker: return "Marker"
        case .highlighter: return "Highlighter"
        case .brush: return "Brush"
        case .calligraphy: return "Calligraphy"
        case .eraserPixel: return "Pixel Eraser"
        case .eraserStroke: return "Stroke Eraser"
        case .lasso: return "Lasso"
        case .ruler: return "Ruler"
        }
    }
    
    var systemImage: String {
        switch self {
        case .fountainPen: return "pencil.and.outline"
        case .pencil: return "pencil"
        case .marker: return "pencil.tip"
        case .highlighter: return "highlighter"
        case .brush: return "paintbrush"
        case .calligraphy: return "paintbrush.pointed"
        case .eraserPixel: return "eraser"
        case .eraserStroke: return "eraser.line.dashed"
        case .lasso: return "lasso"
        case .ruler: return "ruler"
        }
    }
    
    /// Whether this tool produces ink strokes
    var isInkTool: Bool {
        switch self {
        case .fountainPen, .pencil, .marker, .highlighter, .brush, .calligraphy:
            return true
        case .eraserPixel, .eraserStroke, .lasso, .ruler:
            return false
        }
    }
    
    /// Whether this is an eraser variant
    var isEraser: Bool {
        self == .eraserPixel || self == .eraserStroke
    }
    
    /// Convert to a PencilKit tool instance
    func toPKTool(color: UIColor, width: CGFloat) -> PKTool {
        switch self {
        case .fountainPen:
            return PKInkingTool(.pen, color: color, width: width)
        case .pencil:
            return PKInkingTool(.pencil, color: color, width: width)
        case .marker:
            return PKInkingTool(.marker, color: color, width: width)
        case .highlighter:
            return PKInkingTool(.marker, color: color.withAlphaComponent(0.4), width: max(width, 12))
        case .brush:
            return PKInkingTool(.pen, color: color, width: width)
        case .calligraphy:
            return PKInkingTool(.pen, color: color, width: width)
        case .eraserPixel:
            return PKEraserTool(.bitmap, width: width)
        case .eraserStroke:
            return PKEraserTool(.vector)
        case .lasso:
            return PKLassoTool()
        case .ruler:
            return PKInkingTool(.pen, color: color, width: width)
        }
    }
}
