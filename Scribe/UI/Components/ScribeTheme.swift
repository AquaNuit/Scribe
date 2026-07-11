// ScribeTheme.swift
// Scribe — Design system constants and theme definitions

import SwiftUI

enum ScribeTheme {
    
    // MARK: - Colors
    
    static let accentColor = Color(hex: "#5B7FFF")!
    
    static let notebookColors: [String] = [
        "#5B7FFF", "#FF6B6B", "#2ECC71", "#F39C12", "#9B59B6",
        "#1ABC9C", "#E74C3C", "#3498DB", "#E67E22", "#34495E",
        "#FF8ED4", "#00B894", "#6C5CE7", "#FDCB6E", "#636E72"
    ]
    
    // MARK: - Canvas
    
    static let defaultPageSize = CGSize(width: 768, height: 1024)
    static let a4PageSize = CGSize(width: 595, height: 842)  // 72 DPI
    static let letterPageSize = CGSize(width: 612, height: 792) // 72 DPI
    
    // MARK: - Typography
    
    static let titleFont = Font.system(.title, design: .rounded, weight: .bold)
    static let headlineFont = Font.system(.headline, design: .rounded, weight: .semibold)
    static let bodyFont = Font.system(.body, design: .default)
    static let captionFont = Font.system(.caption, design: .default)
    
    // MARK: - Layout
    
    static let sidebarWidth: CGFloat = 280
    static let toolPaletteHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    
    // MARK: - Animation
    
    static let quickAnimation = Animation.easeInOut(duration: 0.15)
    static let standardAnimation = Animation.easeInOut(duration: 0.25)
    static let springAnimation = Animation.spring(duration: 0.35, bounce: 0.2)
}
