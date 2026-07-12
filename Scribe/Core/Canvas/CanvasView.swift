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
    var onBackgroundColorResolved: ((UIColor) -> Void)?
    
    func makeUIViewController(context: Context) -> CanvasViewController {
        let controller = CanvasViewController()
        controller.delegate = context.coordinator
        controller.onBackgroundColorResolved = onBackgroundColorResolved
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
        // Update tool
        controller.updateTool(from: toolState)
        
        // Update template if it changed (this is what was missing before)
        let currentTemplate = template
        controller.updateTemplate(currentTemplate)
        
        // Update appearance
        controller.updateAppearance(appearance)
        
        // Sync background color callback
        controller.onBackgroundColorResolved = onBackgroundColorResolved
        
        // Update canvas mode if changed
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
