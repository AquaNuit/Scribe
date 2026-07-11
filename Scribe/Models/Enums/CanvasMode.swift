// CanvasMode.swift
// Scribe — Canvas mode enumeration

import Foundation

/// Defines the canvas behavior mode
enum CanvasMode: String, Codable, CaseIterable, Identifiable {
    /// Fixed-size page with defined dimensions
    case page = "page"
    
    /// Infinite canvas that expands as the user draws
    case whiteboard = "whiteboard"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .page: return "Page"
        case .whiteboard: return "Whiteboard"
        }
    }
    
    var systemImage: String {
        switch self {
        case .page: return "doc"
        case .whiteboard: return "rectangle.expand.vertical"
        }
    }
}
