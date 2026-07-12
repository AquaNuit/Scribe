// CanvasAppearance.swift
// Scribe — Canvas appearance mode enumeration

import Foundation

/// Controls the visual appearance of the canvas background independently of system theme
enum CanvasAppearance: String, Codable, CaseIterable, Identifiable {
    /// Follow the system light/dark mode
    case system = "system"
    
    /// Force light background regardless of system theme
    case light = "light"
    
    /// Force dark background regardless of system theme
    case dark = "dark"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var systemImage: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
