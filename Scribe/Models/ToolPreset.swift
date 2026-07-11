// ToolPreset.swift
// Scribe — Saved tool configurations

import Foundation
import PencilKit

struct ToolPreset: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var toolType: ToolType
    var colorHex: String
    var lineWidth: CGFloat
    var opacity: CGFloat
    var pressureSensitivity: CGFloat
    
    init(
        name: String,
        toolType: ToolType,
        colorHex: String = "#000000",
        lineWidth: CGFloat = 3.0,
        opacity: CGFloat = 1.0,
        pressureSensitivity: CGFloat = 1.0
    ) {
        self.id = UUID()
        self.name = name
        self.toolType = toolType
        self.colorHex = colorHex
        self.lineWidth = lineWidth
        self.opacity = opacity
        self.pressureSensitivity = pressureSensitivity
    }
    
    // MARK: - Default Presets
    
    static let defaultPen = ToolPreset(
        name: "Fine Pen",
        toolType: .fountainPen,
        colorHex: "#1A1A2E",
        lineWidth: 2.0
    )
    
    static let thickPen = ToolPreset(
        name: "Thick Pen",
        toolType: .fountainPen,
        colorHex: "#1A1A2E",
        lineWidth: 5.0
    )
    
    static let pencil = ToolPreset(
        name: "Pencil",
        toolType: .pencil,
        colorHex: "#3A3A3A",
        lineWidth: 3.0,
        opacity: 0.85
    )
    
    static let marker = ToolPreset(
        name: "Marker",
        toolType: .marker,
        colorHex: "#2D3436",
        lineWidth: 8.0
    )
    
    static let highlighter = ToolPreset(
        name: "Highlighter",
        toolType: .highlighter,
        colorHex: "#FDCB6E",
        lineWidth: 16.0,
        opacity: 0.4
    )
    
    static let allDefaults: [ToolPreset] = [
        .defaultPen, .thickPen, .pencil, .marker, .highlighter
    ]
}
