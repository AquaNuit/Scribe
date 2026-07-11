// BrushEngine.swift
// Scribe — Brush preset management and stroke characteristic calculations

import Foundation
import PencilKit
import UIKit

/// Manages brush presets and generates PKInkingTool instances with proper characteristics
final class BrushEngine {
    
    // MARK: - Brush Characteristics
    
    struct BrushCharacteristics {
        let inkType: PKInkingTool.InkType
        let widthMultiplier: CGFloat
        let opacityMultiplier: CGFloat
        let smoothing: CGFloat
        let pressureCurve: PencilEngine.PressureCurve
    }
    
    // MARK: - Built-in Brushes
    
    static func characteristics(for toolType: ToolType) -> BrushCharacteristics {
        switch toolType {
        case .fountainPen:
            return BrushCharacteristics(
                inkType: .pen,
                widthMultiplier: 1.0,
                opacityMultiplier: 1.0,
                smoothing: 0.5,
                pressureCurve: .soft
            )
        case .pencil:
            return BrushCharacteristics(
                inkType: .pencil,
                widthMultiplier: 1.2,
                opacityMultiplier: 0.85,
                smoothing: 0.3,
                pressureCurve: .linear
            )
        case .marker:
            return BrushCharacteristics(
                inkType: .marker,
                widthMultiplier: 2.5,
                opacityMultiplier: 1.0,
                smoothing: 0.6,
                pressureCurve: .firm
            )
        case .highlighter:
            return BrushCharacteristics(
                inkType: .marker,
                widthMultiplier: 4.0,
                opacityMultiplier: 0.4,
                smoothing: 0.7,
                pressureCurve: .linear
            )
        case .brush:
            return BrushCharacteristics(
                inkType: .pen,
                widthMultiplier: 1.5,
                opacityMultiplier: 0.9,
                smoothing: 0.8,
                pressureCurve: .calligraphy
            )
        case .calligraphy:
            return BrushCharacteristics(
                inkType: .pen,
                widthMultiplier: 1.8,
                opacityMultiplier: 1.0,
                smoothing: 0.4,
                pressureCurve: .calligraphy
            )
        default:
            return BrushCharacteristics(
                inkType: .pen,
                widthMultiplier: 1.0,
                opacityMultiplier: 1.0,
                smoothing: 0.5,
                pressureCurve: .linear
            )
        }
    }
    
    /// Create a PKInkingTool for the given tool type with custom settings
    static func createTool(
        type: ToolType,
        color: UIColor,
        width: CGFloat
    ) -> PKTool {
        let chars = characteristics(for: type)
        let adjustedWidth = width * chars.widthMultiplier
        let adjustedColor = color.withAlphaComponent(
            color.cgColor.alpha * chars.opacityMultiplier
        )
        
        return PKInkingTool(chars.inkType, color: adjustedColor, width: adjustedWidth)
    }
}
