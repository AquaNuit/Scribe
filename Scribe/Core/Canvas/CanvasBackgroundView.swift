// CanvasBackgroundView.swift
// Scribe — Renders canvas background patterns (grid, dots, lines, etc.)
// Pinned to all 4 edges of the PKCanvasView content layout guide so it
// expands with the content in whiteboard mode.

import UIKit

final class CanvasBackgroundView: UIView {
    
    // MARK: - Properties
    
    private var template: Template = .blank
    private var appearance: CanvasAppearance = .system
    
    private var lineColor: UIColor = UIColor.systemGray4
    private var backgroundColor_: UIColor = .white
    private var isDarkMode: Bool = false
    
    // MARK: - Configuration
    
    /// Configure the background with a template and appearance override
    /// - Parameters:
    ///   - template: The page template (defines grid/lines/dots etc.)
    ///   - appearance: Light/dark/system appearance override
    ///   - traitCollection: The trait collection to use for system appearance detection
    func configure(with template: Template, appearance: CanvasAppearance, traitCollection: UITraitCollection) {
        self.template = template
        self.appearance = appearance
        applyCurrentAppearance(with: traitCollection)
    }
    
    /// Update only the appearance (when user toggles light/dark)
    func updateAppearance(_ appearance: CanvasAppearance, traitCollection: UITraitCollection) {
        self.appearance = appearance
        applyCurrentAppearance(with: traitCollection)
    }
    
    /// Resolve and apply colors from current template + appearance
    private func applyCurrentAppearance(with traitCollection: UITraitCollection) {
        let systemDark = traitCollection.userInterfaceStyle == .dark
        self.isDarkMode = resolveDarkMode(appearance: appearance, systemDark: systemDark)
        
        self.lineColor = UIColor(hex: template.lineColor)?
            .withAlphaComponent(isDarkMode ? 0.25 : 0.35) ?? .systemGray4
        
        // When the user explicitly picks Light or Dark, use pure colors.
        // In .system mode, use warm paper-like tones.
        switch appearance {
        case .dark:
            backgroundColor_ = UIColor.black
        case .light:
            backgroundColor_ = UIColor.white
        case .system:
            if isDarkMode {
                backgroundColor_ = UIColor(red: 0.08, green: 0.08, blue: 0.09, alpha: 1.0)
            } else {
                backgroundColor_ = UIColor(red: 1.0, green: 0.99, blue: 0.97, alpha: 1.0)
            }
        }
        
        setNeedsDisplay()
    }
    
    // MARK: - Appearance Resolution
    
    private func resolveDarkMode(appearance: CanvasAppearance, systemDark: Bool) -> Bool {
        switch appearance {
        case .system:  return systemDark
        case .light:   return false
        case .dark:    return true
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Redraw when the view's bounds change (e.g., content expansion)
        setNeedsDisplay()
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Fill entire bounds with background color
        context.setFillColor(backgroundColor_.cgColor)
        context.fill(bounds)
        
        // Draw pattern across the entire view bounds
        switch template.backgroundStyle {
        case .blank:
            break
        case .lined:
            drawLines(in: bounds, context: context)
        case .grid:
            drawGrid(in: bounds, context: context)
        case .dotGrid:
            drawDotGrid(in: bounds, context: context)
        case .musicStaff:
            drawMusicStaff(in: bounds, context: context)
        case .engineeringGraph:
            drawEngineeringGraph(in: bounds, context: context)
        case .cornell:
            drawCornellLayout(in: bounds, context: context)
        case .isometric:
            drawIsometricGrid(in: bounds, context: context)
        }
    }
    
    // MARK: - Pattern Renderers
    
    private func drawLines(in rect: CGRect, context: CGContext) {
        let spacing = template.lineSpacing
        let topMargin: CGFloat = 80
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(0.5)
        
        var y = topMargin
        while y < rect.maxY {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += spacing
        }
        context.strokePath()
        
        // Left margin line
        let marginColor = UIColor.systemRed.withAlphaComponent(isDarkMode ? 0.2 : 0.3)
        context.setStrokeColor(marginColor.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: rect.minX + 72, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.minX + 72, y: rect.maxY))
        context.strokePath()
    }
    
    private func drawGrid(in rect: CGRect, context: CGContext) {
        let spacing = template.gridSize
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(0.5)
        
        // Vertical lines
        var x: CGFloat = rect.minX
        while x <= rect.maxX {
            context.move(to: CGPoint(x: x, y: rect.minY))
            context.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += spacing
        }
        
        // Horizontal lines
        var y: CGFloat = rect.minY
        while y <= rect.maxY {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += spacing
        }
        
        context.strokePath()
    }
    
    private func drawDotGrid(in rect: CGRect, context: CGContext) {
        let spacing = template.gridSize
        let dotRadius: CGFloat = 1.2
        
        context.setFillColor(lineColor.cgColor)
        
        var x: CGFloat = rect.minX + spacing
        while x < rect.maxX {
            var y: CGFloat = rect.minY + spacing
            while y < rect.maxY {
                context.fillEllipse(in: CGRect(
                    x: x - dotRadius,
                    y: y - dotRadius,
                    width: dotRadius * 2,
                    height: dotRadius * 2
                ))
                y += spacing
            }
            x += spacing
        }
    }
    
    private func drawMusicStaff(in rect: CGRect, context: CGContext) {
        let staffSpacing = template.lineSpacing
        let staffGroupSpacing: CGFloat = 72
        let topMargin: CGFloat = 60
        let linesPerStaff = 5
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(0.8)
        
        var staffY = rect.minY + topMargin
        while staffY < rect.maxY - CGFloat(linesPerStaff) * staffSpacing {
            for line in 0..<linesPerStaff {
                let y = staffY + CGFloat(line) * staffSpacing
                context.move(to: CGPoint(x: rect.minX + 40, y: y))
                context.addLine(to: CGPoint(x: rect.maxX - 40, y: y))
            }
            staffY += CGFloat(linesPerStaff) * staffSpacing + staffGroupSpacing
        }
        
        context.strokePath()
    }
    
    private func drawEngineeringGraph(in rect: CGRect, context: CGContext) {
        let smallSpacing = template.gridSize
        let largeSpacing = smallSpacing * 5
        
        // Small grid
        context.setStrokeColor(lineColor.withAlphaComponent(0.15).cgColor)
        context.setLineWidth(0.3)
        
        var x: CGFloat = rect.minX
        while x <= rect.maxX {
            context.move(to: CGPoint(x: x, y: rect.minY))
            context.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += smallSpacing
        }
        
        var y: CGFloat = rect.minY
        while y <= rect.maxY {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += smallSpacing
        }
        context.strokePath()
        
        // Large grid (every 5th line)
        context.setStrokeColor(lineColor.withAlphaComponent(0.4).cgColor)
        context.setLineWidth(0.7)
        
        x = rect.minX
        while x <= rect.maxX {
            context.move(to: CGPoint(x: x, y: rect.minY))
            context.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += largeSpacing
        }
        
        y = rect.minY
        while y <= rect.maxY {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += largeSpacing
        }
        context.strokePath()
    }
    
    private func drawCornellLayout(in rect: CGRect, context: CGContext) {
        let spacing = template.lineSpacing
        let cueColumnWidth: CGFloat = 200
        let summaryHeight: CGFloat = 160
        let topMargin: CGFloat = 80
        
        // Draw lines in the note-taking area
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(0.5)
        
        var y = rect.minY + topMargin
        while y < rect.maxY - summaryHeight {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += spacing
        }
        context.strokePath()
        
        // Cue column divider
        let dividerColor = lineColor.withAlphaComponent(0.6)
        context.setStrokeColor(dividerColor.cgColor)
        context.setLineWidth(1.5)
        
        context.move(to: CGPoint(x: rect.minX + cueColumnWidth, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.minX + cueColumnWidth, y: rect.maxY - summaryHeight))
        context.strokePath()
        
        // Summary area divider
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY - summaryHeight))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - summaryHeight))
        context.strokePath()
    }
    
    private func drawIsometricGrid(in rect: CGRect, context: CGContext) {
        let spacing = template.gridSize
        let height = spacing * sqrt(3) / 2
        
        context.setStrokeColor(lineColor.withAlphaComponent(0.25).cgColor)
        context.setLineWidth(0.4)
        
        // Horizontal lines
        var y: CGFloat = rect.minY
        while y <= rect.maxY {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += height
        }
        
        // Diagonal lines (top-left to bottom-right)
        let maxDiag = rect.width + rect.height
        var offset: CGFloat = -maxDiag
        while offset <= maxDiag {
            context.move(to: CGPoint(x: rect.minX + offset, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.minX + offset + rect.height / tan(.pi / 3), y: rect.maxY))
            offset += spacing
        }
        
        // Diagonal lines (top-right to bottom-left)
        offset = -maxDiag
        while offset <= maxDiag {
            context.move(to: CGPoint(x: rect.minX + offset, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.minX + offset - rect.height / tan(.pi / 3), y: rect.maxY))
            offset += spacing
        }
        
        context.strokePath()
    }
}
