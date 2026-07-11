// CanvasViewController.swift
// Scribe — UIKit controller hosting the canvas stack (PencilKit + CoreGraphics background)

import UIKit
import PencilKit

// MARK: - Delegate Protocol

protocol CanvasViewControllerDelegate: AnyObject {
    func canvasDrawingDidChange(_ drawing: PKDrawing)
    func canvasDidBeginDrawing()
    func canvasDidEndDrawing()
}

// MARK: - Canvas View Controller

final class CanvasViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: CanvasViewControllerDelegate?
    
    private(set) var canvasView: PKCanvasView!
    private var backgroundView: CanvasBackgroundView!
    
    private var currentCanvasSize: CGSize = CGSize(width: 768, height: 1024)
    private var currentTemplate: Template = .blank
    private var lastKnownDrawing: PKDrawing?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvas()
        setupBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Become first responder to receive pencil events
        canvasView.becomeFirstResponder()
    }
    
    // MARK: - Setup
    
    private func setupCanvas() {
        canvasView = PKCanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .pencilOnly
        canvasView.delegate = self
        
        // Performance optimizations
        canvasView.isScrollEnabled = true
        canvasView.showsVerticalScrollIndicator = true
        canvasView.showsHorizontalScrollIndicator = true
        canvasView.bouncesZoom = true
        canvasView.minimumZoomScale = 0.25
        canvasView.maximumZoomScale = 8.0
        
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBackground() {
        backgroundView = CanvasBackgroundView(frame: .zero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // Insert background behind the canvas drawing
        canvasView.insertSubview(backgroundView, at: 0)
        
        updateBackgroundSize()
    }
    
    // MARK: - Configuration
    
    func configure(
        drawing: PKDrawing,
        canvasSize: CGSize,
        backgroundStyle: BackgroundStyle,
        template: Template
    ) {
        self.currentCanvasSize = canvasSize
        self.currentTemplate = template
        self.canvasView?.drawing = drawing
        self.lastKnownDrawing = drawing
        
        updateBackgroundSize()
        let isDark = traitCollection.userInterfaceStyle == .dark
        backgroundView?.configure(with: template, isDarkMode: isDark)
    }
    
    func updateTool(from toolState: ToolState) {
        guard let canvasView = canvasView else { return }
        
        let color = UIColor(hex: toolState.currentColorHex) ?? .black
        let pkTool = toolState.currentToolType.toPKTool(
            color: color,
            width: toolState.currentLineWidth
        )
        canvasView.tool = pkTool
        
        // Update ruler visibility
        canvasView.isRulerActive = toolState.isRulerActive
        
        // Update drawing policy
        canvasView.drawingPolicy = toolState.fingerDrawingEnabled ? .anyInput : .pencilOnly
    }
    
    func updateDrawingIfNeeded(_ drawing: PKDrawing) {
        guard canvasView.drawing != drawing else { return }
        canvasView.drawing = drawing
        lastKnownDrawing = drawing
    }
    
    // MARK: - Private
    
    private func updateBackgroundSize() {
        guard let backgroundView = backgroundView else { return }
        
        let size = currentCanvasSize
        canvasView.contentSize = size
        
        backgroundView.frame = CGRect(origin: .zero, size: size)
        
        NSLayoutConstraint.deactivate(backgroundView.constraints)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.widthAnchor.constraint(equalToConstant: size.width),
            backgroundView.heightAnchor.constraint(equalToConstant: size.height),
            backgroundView.topAnchor.constraint(equalTo: canvasView.contentLayoutGuide.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: canvasView.contentLayoutGuide.leadingAnchor)
        ])
    }
}

// MARK: - PKCanvasViewDelegate

extension CanvasViewController: PKCanvasViewDelegate {
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let newDrawing = canvasView.drawing
        
        // Avoid feedback loops
        guard newDrawing != lastKnownDrawing else { return }
        lastKnownDrawing = newDrawing
        
        delegate?.canvasDrawingDidChange(newDrawing)
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        delegate?.canvasDidBeginDrawing()
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        delegate?.canvasDidEndDrawing()
    }
}
