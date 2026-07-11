// BackgroundStyle.swift
// Scribe — Canvas background style enumeration

import Foundation

/// Available canvas background patterns
enum BackgroundStyle: String, Codable, CaseIterable, Identifiable {
    case blank = "blank"
    case lined = "lined"
    case grid = "grid"
    case dotGrid = "dotGrid"
    case musicStaff = "musicStaff"
    case engineeringGraph = "engineeringGraph"
    case cornell = "cornell"
    case isometric = "isometric"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .blank: return "Blank"
        case .lined: return "Lined"
        case .grid: return "Grid"
        case .dotGrid: return "Dot Grid"
        case .musicStaff: return "Music Staff"
        case .engineeringGraph: return "Engineering"
        case .cornell: return "Cornell Notes"
        case .isometric: return "Isometric"
        }
    }
    
    var systemImage: String {
        switch self {
        case .blank: return "doc"
        case .lined: return "line.3.horizontal"
        case .grid: return "grid"
        case .dotGrid: return "circle.grid.3x3"
        case .musicStaff: return "music.note.list"
        case .engineeringGraph: return "square.grid.4x3.fill"
        case .cornell: return "rectangle.split.2x1"
        case .isometric: return "cube"
        }
    }
}
