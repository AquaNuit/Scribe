// CanvasBackgroundView.swift
// Scribe — Renders canvas background patterns (grid, dots, lines, etc.)
// Frame is manually managed by CanvasViewController to exactly match contentSize.

import UIKit

final class CanvasBackgroundView: UIView {
    
    // MARK: - Properties
    
    private var template: Template = .blank
    private var appearance: CanvasAppearance = .system
    
    private var lineColor: UIColor = UIColor.systemGray4
    private var resolvedBgColor: UIColor = .white
    private var isDarkMode: Bool = false
    
    /// The currently resolved background color, accessible from outside
    var resolvedBackgroundColor: UIColor { resolvedBgColor }
    
    // MARK: - Configuration
    
    func configure(with template: Template, appearance: CanvasAppearance, traitCollection: UITraitCollection) {
        self.template = template
        self.appearance = appearance
        resolveColors(with: traitCollection)
        setNeedsDisplay()
    }
    
    func updateAppearance(_ appearance: CanvasAppearance, traitCollection: UITraitCollection) {
        self.appearance = appearance
        resolveColors(with: traitCollection)
        setNeedsDisplay()
    }
    
    // MARK: - Color Resolution
    
    private func resolveColors(with traitCollection: UITraitCollection) {
        let systemDark = traitCollection.userInterfaceStyle == .dark
        
        switch appearance {
        case .system: isDarkMode = systemDark
        case .light:  isDarkMode = false
        case .dark:   isDarkMode = true
        }
        
        // Resolve line color from template
        let baseLineColor = UIColor(hex: template.lineColor) ?? .systemGray4
        lineColor = baseLineColor.withAlphaComponent(isDarkMode ? 0.3 : 0.4)
        
        // Resolve background color
        switch appearance {
        case .dark:
            resolvedBgColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        case .light:
            resolvedBgColor = UIColor(red: 1.0, green: 0.995, blue: 0.98, alpha: 1.0)
        case .system:
            if isDarkMode {
                resolvedBgColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
            } else {
                resolvedBgColor = UIColor(red: 1.0, green: 0.995, blue: 0.98, alpha: 1.0)
            }
        }
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Fill entire bounds with resolved background color
        context.setFillColor(resolvedBgColor.cgColor)
        context.fill(bounds)
        
        // Draw the appropriate pattern
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
        let marginColor = isDarkMode
            ? UIColor.systemRed.withAlphaComponent(0.2)
            : UIColor.systemRed.withAlphaComponent(0.3)
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
        
        var x: CGFloat = rect.minX
        while x <= rect.maxX {
            context.move(to: CGPoint(x: x, y: rect.minY))
            context.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += spacing
        }
        
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
        
        // Large grid
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
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(0.5)
        
        var y = rect.minY + topMargin
        while y < rect.maxY - summaryHeight {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += spacing
        }
        context.strokePath()
        
        let dividerColor = lineColor.withAlphaComponent(0.6)
        context.setStrokeColor(dividerColor.cgColor)
        context.setLineWidth(1.5)
        
        context.move(to: CGPoint(x: rect.minX + cueColumnWidth, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.minX + cueColumnWidth, y: rect.maxY - summaryHeight))
        context.strokePath()
        
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY - summaryHeight))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - summaryHeight))
        context.strokePath()
    }
    
    private func drawIsometricGrid(in rect: CGRect, context: CGContext) {
        let spacing = template.gridSize
        let height = spacing * sqrt(3) / 2
        
        context.setStrokeColor(lineColor.withAlphaComponent(0.25).cgColor)
        context.setLineWidth(0.4)
        
        var y: CGFloat = rect.minY
        while y <= rect.maxY {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += height
        }
        
        let maxDiag = rect.width + rect.height
        var offset: CGFloat = -maxDiag
        while offset <= maxDiag {
            context.move(to: CGPoint(x: rect.minX + offset, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.minX + offset + rect.height / tan(.pi / 3), y: rect.maxY))
            offset += spacing
        }
        
        offset = -maxDiag
        while offset <= maxDiag {
            context.move(to: CGPoint(x: rect.minX + offset, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.minX + offset - rect.height / tan(.pi / 3), y: rect.maxY))
            offset += spacing
        }
        
        context.strokePath()
    }
}
