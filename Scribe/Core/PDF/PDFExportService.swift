// PDFExportService.swift
// Scribe — Export notebooks and pages as PDF

import Foundation
import PDFKit
import PencilKit
import UIKit
import OSLog

final class PDFExportService {
    
    /// Export a single page to PDF data
    static func exportPage(_ page: Page) -> Data? {
        let pageSize = page.canvasSize
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            
            // Draw background
            drawBackground(
                in: context.cgContext,
                size: pageSize,
                style: page.backgroundStyle
            )
            
            // Draw the PK drawing
            if let drawing = page.drawing {
                let image = drawing.image(
                    from: CGRect(origin: .zero, size: pageSize),
                    scale: 2.0
                )
                image.draw(in: CGRect(origin: .zero, size: pageSize))
            }
        }
        
        return data
    }
    
    /// Export an entire notebook to PDF data
    static func exportNotebook(_ notebook: Notebook) -> Data? {
        let allPages = notebook.sortedSections.flatMap { $0.sortedPages }
        guard !allPages.isEmpty else { return nil }
        
        let firstPageSize = allPages.first?.canvasSize ?? ScribeTheme.defaultPageSize
        let pdfRenderer = UIGraphicsPDFRenderer(
            bounds: CGRect(origin: .zero, size: firstPageSize)
        )
        
        let data = pdfRenderer.pdfData { context in
            for page in allPages {
                let pageRect = CGRect(origin: .zero, size: page.canvasSize)
                
                var pageInfo: [String: Any] = [:]
                pageInfo[kCGPDFContextMediaBox as String] = pageRect
                
                context.beginPage(withBounds: pageRect, pageInfo: pageInfo as [String: Any])
                
                // Background
                drawBackground(
                    in: context.cgContext,
                    size: page.canvasSize,
                    style: page.backgroundStyle
                )
                
                // Drawing
                if let drawing = page.drawing {
                    let image = drawing.image(
                        from: pageRect,
                        scale: 2.0
                    )
                    image.draw(in: pageRect)
                }
            }
        }
        
        Logger.pdf.info("Exported notebook '\(notebook.title)' with \(allPages.count) pages")
        
        return data
    }
    
    /// Export page as PNG image
    static func exportPageAsImage(_ page: Page, scale: CGFloat = 2.0) -> UIImage? {
        let pageSize = page.canvasSize
        let renderer = UIGraphicsImageRenderer(size: pageSize)
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: pageSize))
            
            // Drawing
            if let drawing = page.drawing {
                let image = drawing.image(
                    from: CGRect(origin: .zero, size: pageSize),
                    scale: scale
                )
                image.draw(in: CGRect(origin: .zero, size: pageSize))
            }
        }
    }
    
    // MARK: - Private
    
    private static func drawBackground(
        in context: CGContext,
        size: CGSize,
        style: BackgroundStyle
    ) {
        // White background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        let lineColor = UIColor.systemGray4.cgColor
        
        switch style {
        case .blank:
            break
            
        case .lined:
            context.setStrokeColor(lineColor)
            context.setLineWidth(0.5)
            var y: CGFloat = 80
            while y < size.height {
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: size.width, y: y))
                y += 28
            }
            context.strokePath()
            
        case .grid:
            context.setStrokeColor(lineColor)
            context.setLineWidth(0.3)
            let spacing: CGFloat = 24
            var x: CGFloat = 0
            while x <= size.width {
                context.move(to: CGPoint(x: x, y: 0))
                context.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            var y: CGFloat = 0
            while y <= size.height {
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            context.strokePath()
            
        case .dotGrid:
            context.setFillColor(lineColor)
            let spacing: CGFloat = 24
            var x: CGFloat = spacing
            while x < size.width {
                var y: CGFloat = spacing
                while y < size.height {
                    context.fillEllipse(in: CGRect(x: x - 1, y: y - 1, width: 2, height: 2))
                    y += spacing
                }
                x += spacing
            }
            
        default:
            break
        }
    }
}
