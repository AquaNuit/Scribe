// CanvasBackgroundView.swift
// Scribe — Renders canvas background patterns (grid, dots, lines, etc.)

import UIKit

final class CanvasBackgroundView: UIView {
    
    // MARK: - Properties
    
    private var template: Template = .blank
    private var isDarkMode: Bool = false
    
    private var lineColor: UIColor = UIColor.systemGray4
    private var backgroundColor_: UIColor = .white
    
    // MARK: - Configuration
    
    func configure(with template: Template, isDarkMode: Bool) {
        self.template = template
        self.isDarkMode = isDarkMode
        
        self.lineColor = UIColor(hex: template.lineColor)?
            .withAlphaComponent(isDarkMode ? 0.25 : 0.35) ?? .systemGray4
        self.backgroundColor_ = isDarkMode
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.99, blue: 0.97, alpha: 1.0)
        
        setNeedsDisplay()
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Fill background
        context.setFillColor(backgroundColor_.cgColor)
        context.fill(rect)
        
        // Draw pattern
        switch template.backgroundStyle {
        case .blank:
            break
        case .lined:
            drawLines(in: rect, context: context)
        case .grid:
            drawGrid(in: rect, context: context)
        case .dotGrid:
            drawDotGrid(in: rect, context: context)
        case .musicStaff:
            drawMusicStaff(in: rect, context: context)
        case .engineeringGraph:
            drawEngineeringGraph(in: rect, context: context)
        case .cornell:
            drawCornellLayout(in: rect, context: context)
        case .isometric:
            drawIsometricGrid(in: rect, context: context)
        }
    }
    
    // MARK: - Pattern Renderers
    
    private func drawLines(in rect: CGRect, context: CGContext) {
        let spacing = template.lineSpacing
        let topMargin: CGFloat = 80
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(0.5)
        
        var y = topMargin
        while y < rect.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            y += spacing
        }
        context.strokePath()
        
        // Left margin line
        let marginColor = UIColor.systemRed.withAlphaComponent(isDarkMode ? 0.2 : 0.3)
        context.setStrokeColor(marginColor.cgColor)
        context.setLineWidth(1.0)
        context.move(to: CGPoint(x: 72, y: 0))
        context.addLine(to: CGPoint(x: 72, y: rect.height))
        context.strokePath()
    }
    
    private func drawGrid(in rect: CGRect, context: CGContext) {
        let spacing = template.gridSize
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(0.5)
        
        // Vertical lines
        var x: CGFloat = 0
        while x <= rect.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
            x += spacing
        }
        
        // Horizontal lines
        var y: CGFloat = 0
        while y <= rect.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            y += spacing
        }
        
        context.strokePath()
    }
    
    private func drawDotGrid(in rect: CGRect, context: CGContext) {
        let spacing = template.gridSize
        let dotRadius: CGFloat = 1.2
        
        context.setFillColor(lineColor.cgColor)
        
        var x: CGFloat = spacing
        while x < rect.width {
            var y: CGFloat = spacing
            while y < rect.height {
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
        
        var staffY = topMargin
        while staffY < rect.height - CGFloat(linesPerStaff) * staffSpacing {
            for line in 0..<linesPerStaff {
                let y = staffY + CGFloat(line) * staffSpacing
                context.move(to: CGPoint(x: 40, y: y))
                context.addLine(to: CGPoint(x: rect.width - 40, y: y))
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
        
        var x: CGFloat = 0
        while x <= rect.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
            x += smallSpacing
        }
        
        var y: CGFloat = 0
        while y <= rect.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            y += smallSpacing
        }
        context.strokePath()
        
        // Large grid (every 5th line)
        context.setStrokeColor(lineColor.withAlphaComponent(0.4).cgColor)
        context.setLineWidth(0.7)
        
        x = 0
        while x <= rect.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
            x += largeSpacing
        }
        
        y = 0
        while y <= rect.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
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
        
        var y = topMargin
        while y < rect.height - summaryHeight {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            y += spacing
        }
        context.strokePath()
        
        // Cue column divider
        let dividerColor = lineColor.withAlphaComponent(0.6)
        context.setStrokeColor(dividerColor.cgColor)
        context.setLineWidth(1.5)
        
        context.move(to: CGPoint(x: cueColumnWidth, y: 0))
        context.addLine(to: CGPoint(x: cueColumnWidth, y: rect.height - summaryHeight))
        context.strokePath()
        
        // Summary area divider
        context.move(to: CGPoint(x: 0, y: rect.height - summaryHeight))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height - summaryHeight))
        context.strokePath()
    }
    
    private func drawIsometricGrid(in rect: CGRect, context: CGContext) {
        let spacing = template.gridSize
        let height = spacing * sqrt(3) / 2
        
        context.setStrokeColor(lineColor.withAlphaComponent(0.25).cgColor)
        context.setLineWidth(0.4)
        
        // Horizontal lines
        var y: CGFloat = 0
        while y <= rect.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            y += height
        }
        
        // Diagonal lines (top-left to bottom-right)
        let maxDiag = rect.width + rect.height
        var offset: CGFloat = -maxDiag
        while offset <= maxDiag {
            context.move(to: CGPoint(x: offset, y: 0))
            context.addLine(to: CGPoint(x: offset + rect.height / tan(.pi / 3), y: rect.height))
            offset += spacing
        }
        
        // Diagonal lines (top-right to bottom-left)
        offset = -maxDiag
        while offset <= maxDiag {
            context.move(to: CGPoint(x: offset, y: 0))
            context.addLine(to: CGPoint(x: offset - rect.height / tan(.pi / 3), y: rect.height))
            offset += spacing
        }
        
        context.strokePath()
    }
}
