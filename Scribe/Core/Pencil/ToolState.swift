// ToolState.swift
// Scribe — Shared observable state for the current drawing tool

import SwiftUI
import PencilKit

@Observable
final class ToolState {
    
    // MARK: - Current Tool
    
    var currentToolType: ToolType = .fountainPen
    var currentColorHex: String = "#1A1A2E"
    var currentLineWidth: CGFloat = 3.0
    var currentOpacity: CGFloat = 1.0
    
    /// Whether the ruler overlay is active
    var isRulerActive: Bool = false
    
    /// Whether finger drawing is enabled (default: pencil only)
    var fingerDrawingEnabled: Bool = false
    
    /// Recently used colors
    var recentColors: [String] = [
        "#1A1A2E", "#E74C3C", "#3498DB", "#2ECC71", "#F39C12",
        "#9B59B6", "#1ABC9C", "#E67E22"
    ]
    
    /// Saved tool presets
    var presets: [ToolPreset] = ToolPreset.allDefaults
    
    /// The tool that was active before switching to eraser (for toggle behavior)
    private var previousToolType: ToolType?
    private var previousColorHex: String?
    
    // MARK: - Tool Switching
    
    func selectTool(_ type: ToolType) {
        if currentToolType.isInkTool && type.isEraser {
            previousToolType = currentToolType
            previousColorHex = currentColorHex
        }
        currentToolType = type
    }
    
    func selectPreset(_ preset: ToolPreset) {
        currentToolType = preset.toolType
        currentColorHex = preset.colorHex
        currentLineWidth = preset.lineWidth
        currentOpacity = preset.opacity
    }
    
    func toggleEraser() {
        if currentToolType.isEraser {
            // Switch back to previous tool
            currentToolType = previousToolType ?? .fountainPen
            if let prevColor = previousColorHex {
                currentColorHex = prevColor
            }
        } else {
            previousToolType = currentToolType
            previousColorHex = currentColorHex
            currentToolType = .eraserStroke
        }
    }
    
    func switchToPreviousTool() {
        if let prev = previousToolType {
            let current = currentToolType
            currentToolType = prev
            previousToolType = current
            
            if let prevColor = previousColorHex {
                let currentColor = currentColorHex
                currentColorHex = prevColor
                previousColorHex = currentColor
            }
        }
    }
    
    func selectColor(_ hex: String) {
        currentColorHex = hex
        addToRecentColors(hex)
    }
    
    private func addToRecentColors(_ hex: String) {
        recentColors.removeAll { $0 == hex }
        recentColors.insert(hex, at: 0)
        if recentColors.count > 12 {
            recentColors = Array(recentColors.prefix(12))
        }
    }
    
    // MARK: - PencilKit Tool
    
    var currentPKTool: PKTool {
        let color = UIColor(hex: currentColorHex) ?? .black
        return currentToolType.toPKTool(color: color, width: currentLineWidth)
    }
}
