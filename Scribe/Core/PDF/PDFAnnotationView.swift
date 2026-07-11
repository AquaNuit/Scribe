// PDFAnnotationView.swift
// Scribe — PDF page with PencilKit annotation overlay

import SwiftUI
import PDFKit
import PencilKit

/// Displays a PDF page with a PencilKit overlay for annotation
struct PDFAnnotationView: UIViewRepresentable {
    
    let pdfData: Data
    let pageIndex: Int
    @Binding var drawing: PKDrawing
    let toolState: ToolState
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // PDF View
        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        pdfView.pageShadowsEnabled = false
        pdfView.backgroundColor = .white
        
        if let document = PDFDocument(data: pdfData) {
            pdfView.document = document
            if let page = document.page(at: pageIndex) {
                pdfView.go(to: page)
            }
        }
        
        containerView.addSubview(pdfView)
        
        // PencilKit Canvas overlay
        let canvasView = PKCanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .pencilOnly
        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator
        
        containerView.addSubview(canvasView)
        
        // Layout
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            canvasView.topAnchor.constraint(equalTo: containerView.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        
        context.coordinator.canvasView = canvasView
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let canvasView = context.coordinator.canvasView else { return }
        
        let color = UIColor(hex: toolState.currentColorHex) ?? .black
        canvasView.tool = toolState.currentToolType.toPKTool(color: color, width: toolState.currentLineWidth)
        canvasView.drawingPolicy = toolState.fingerDrawingEnabled ? .anyInput : .pencilOnly
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: PDFAnnotationView
        var canvasView: PKCanvasView?
        
        init(parent: PDFAnnotationView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}
