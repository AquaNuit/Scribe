// Template.swift
// Scribe — Canvas template definitions

import Foundation

struct Template: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let backgroundStyle: BackgroundStyle
    let lineSpacing: CGFloat
    let gridSize: CGFloat
    let lineColor: String
    let isBuiltIn: Bool
    let category: TemplateCategory
    
    init(
        name: String,
        backgroundStyle: BackgroundStyle,
        lineSpacing: CGFloat = 28,
        gridSize: CGFloat = 28,
        lineColor: String = "#D0D0D0",
        isBuiltIn: Bool = true,
        category: TemplateCategory = .general
    ) {
        self.id = UUID()
        self.name = name
        self.backgroundStyle = backgroundStyle
        self.lineSpacing = lineSpacing
        self.gridSize = gridSize
        self.lineColor = lineColor
        self.isBuiltIn = isBuiltIn
        self.category = category
    }
    
    // MARK: - Built-in Templates
    
    static let blank = Template(
        name: "Blank",
        backgroundStyle: .blank,
        category: .general
    )
    
    static let lined = Template(
        name: "Lined",
        backgroundStyle: .lined,
        lineSpacing: 28,
        lineColor: "#B8C4CE",
        category: .writing
    )
    
    static let grid = Template(
        name: "Grid",
        backgroundStyle: .grid,
        gridSize: 24,
        lineColor: "#C8D0D8",
        category: .general
    )
    
    static let dotGrid = Template(
        name: "Dot Grid",
        backgroundStyle: .dotGrid,
        gridSize: 24,
        lineColor: "#A0AABC",
        category: .general
    )
    
    static let musicStaff = Template(
        name: "Music Staff",
        backgroundStyle: .musicStaff,
        lineSpacing: 8,
        lineColor: "#A0A8B0",
        category: .music
    )
    
    static let engineeringGraph = Template(
        name: "Engineering Graph",
        backgroundStyle: .engineeringGraph,
        gridSize: 20,
        lineColor: "#88CC88",
        category: .engineering
    )
    
    static let cornell = Template(
        name: "Cornell Notes",
        backgroundStyle: .cornell,
        lineSpacing: 28,
        lineColor: "#B8C4CE",
        category: .writing
    )
    
    static let isometric = Template(
        name: "Isometric",
        backgroundStyle: .isometric,
        gridSize: 28,
        lineColor: "#B8C4CE",
        category: .engineering
    )
    
    static let allBuiltIn: [Template] = [
        .blank, .lined, .grid, .dotGrid,
        .musicStaff, .engineeringGraph, .cornell, .isometric
    ]
}

enum TemplateCategory: String, Codable, CaseIterable {
    case general = "General"
    case writing = "Writing"
    case music = "Music"
    case engineering = "Engineering"
    case custom = "Custom"
}
