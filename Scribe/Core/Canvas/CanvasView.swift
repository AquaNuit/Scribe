// CanvasView.swift
// Scribe — SwiftUI wrapper for the canvas editing surface

import SwiftUI
import PencilKit

/// Main canvas view bridging PencilKit into SwiftUI
struct CanvasView: UIViewControllerRepresentable {
    
    @Binding var drawing: PKDrawing
    @Binding var isDrawing: Bool
    let canvasSize: CGSize
    let backgroundStyle: BackgroundStyle
    let template: Template
    let canvasMode: CanvasMode
    let appearance: CanvasAppearance
    let toolState: ToolState
    let onDrawingChanged: (PKDrawing) -> Void
    var onStrokeBegan: (() -> Void)?
    var onStrokeEnded: (() -> Void)?
    
    func makeUIViewController(context: Context) -> CanvasViewController {
        let controller = CanvasViewController()
        controller.delegate = context.coordinator
        controller.configure(
            drawing: drawing,
            canvasSize: canvasSize,
            backgroundStyle: backgroundStyle,
            template: template,
            canvasMode: canvasMode,
            appearance: appearance
        )
        return controller
    }
    
    func updateUIViewController(_ controller: CanvasViewController, context: Context) {
        controller.updateTool(from: toolState)
        
        // Sync appearance if changed
        controller.updateAppearance(appearance)
        
        // Sync canvas mode if changed
        if controller.configuredMode != canvasMode {
            controller.updateCanvasMode(canvasMode, canvasSize: canvasSize)
        }
        
        // Only update drawing if it changed externally (not from user input)
        if !isDrawing {
            controller.updateDrawingIfNeeded(drawing)
        }
    }
    
    func makeCoordinator() -> CanvasCoordinator {
        CanvasCoordinator(parent: self)
    }
    
    // MARK: - Coordinator
    
    final class CanvasCoordinator: NSObject, CanvasViewControllerDelegate {
        let parent: CanvasView
        
        init(parent: CanvasView) {
            self.parent = parent
        }
        
        func canvasDrawingDidChange(_ drawing: PKDrawing) {
            parent.drawing = drawing
            parent.onDrawingChanged(drawing)
        }
        
        func canvasDidBeginDrawing() {
            parent.isDrawing = true
            parent.onStrokeBegan?()
        }
        
        func canvasDidEndDrawing() {
            parent.isDrawing = false
            parent.onStrokeEnded?()
        }
    }
}
