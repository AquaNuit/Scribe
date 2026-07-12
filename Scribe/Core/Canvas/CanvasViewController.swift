// CanvasViewController.swift
// Scribe — UIKit controller hosting the canvas stack (PencilKit + CoreGraphics background)
// Supports both fixed-page mode and infinite whiteboard mode with dynamic expansion.

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
    private var currentCanvasMode: CanvasMode = .page
    private var currentAppearance: CanvasAppearance = .system
    private var lastKnownDrawing: PKDrawing?
    
    /// Expose the currently configured mode so SwiftUI can detect changes
    private(set) var configuredMode: CanvasMode = .page
    
    /// Pending configuration — applied once the view loads
    private var pendingDrawing: PKDrawing?
    private var pendingCanvasSize: CGSize?
    private var pendingTemplate: Template?
    private var pendingCanvasMode: CanvasMode?
    private var pendingAppearance: CanvasAppearance?
    
    /// Infinite canvas manager — only used in whiteboard mode
    private lazy var infiniteManager: InfiniteCanvasManager = {
        InfiniteCanvasManager(initialSize: currentCanvasSize)
    }()
    
    /// KVO token for observing content size changes
    private var contentSizeObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvas()
        setupBackground()
        applyPendingConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        canvasView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView?.setNeedsDisplay()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            backgroundView?.updateAppearance(currentAppearance, traitCollection: traitCollection)
        }
    }
    
    deinit {
        contentSizeObservation?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupCanvas() {
        canvasView = PKCanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .pencilOnly
        canvasView.delegate = self
        
        // Scroll & zoom configuration
        canvasView.isScrollEnabled = true
        canvasView.showsVerticalScrollIndicator = false
        canvasView.showsHorizontalScrollIndicator = false
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
        
        // Observe content size changes to keep background drawing in sync.
        // Note: worldBounds is managed internally by InfiniteCanvasManager.expandIfNeeded().
        contentSizeObservation = canvasView.observe(\.contentSize, options: [.new]) { [weak self] _, change in
            guard let self = self else { return }
            self.backgroundView?.setNeedsDisplay()
        }
    }
    
    private func setupBackground() {
        backgroundView = CanvasBackgroundView(frame: .zero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.contentMode = .redraw
        
        // Insert background behind the canvas drawing layer
        canvasView.insertSubview(backgroundView, at: 0)
        
        // Pin to content layout guide on all 4 sides — this makes the background
        // follow the PKCanvasView's content area in both page and whiteboard modes.
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: canvasView.contentLayoutGuide.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: canvasView.contentLayoutGuide.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: canvasView.contentLayoutGuide.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: canvasView.contentLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration (may be called before viewDidLoad)
    
    func configure(
        drawing: PKDrawing,
        canvasSize: CGSize,
        backgroundStyle: BackgroundStyle,
        template: Template,
        canvasMode: CanvasMode = .page,
        appearance: CanvasAppearance = .system
    ) {
        // Store for later application
        pendingDrawing = drawing
        pendingCanvasSize = canvasSize
        pendingTemplate = template
        pendingCanvasMode = canvasMode
        pendingAppearance = appearance
        
        // Store the template/background for immediate use
        currentTemplate = template
        currentCanvasMode = canvasMode
        configuredMode = canvasMode
        currentAppearance = appearance
        currentCanvasSize = canvasSize
        
        // If view is already loaded, apply immediately
        if isViewLoaded {
            applyPendingConfiguration()
        }
    }
    
    /// Apply the pending configuration to the canvas and background views
    private func applyPendingConfiguration() {
        guard let canvasView = canvasView,
              let backgroundView = backgroundView else { return }
        
        if let drawing = pendingDrawing {
            canvasView.drawing = drawing
            lastKnownDrawing = drawing
        }
        
        let size = pendingCanvasSize ?? currentCanvasSize
        let template = pendingTemplate ?? currentTemplate
        let mode = pendingCanvasMode ?? currentCanvasMode
        let appearance = pendingAppearance ?? currentAppearance
        
        currentCanvasSize = size
        currentTemplate = template
        currentCanvasMode = mode
        configuredMode = mode
        currentAppearance = appearance
        
        applyContentSize(for: mode, size: size)
        
        backgroundView.setNeedsDisplay()
        backgroundView.configure(
            with: template,
            appearance: appearance,
            traitCollection: traitCollection
        )
    }
    
    func updateCanvasMode(_ mode: CanvasMode, canvasSize: CGSize) {
        currentCanvasMode = mode
        configuredMode = mode
        currentCanvasSize = canvasSize
        pendingCanvasMode = mode
        pendingCanvasSize = canvasSize
        
        guard let canvasView = canvasView else { return }
        
        applyContentSize(for: mode, size: canvasSize)
        backgroundView?.setNeedsDisplay()
    }
    
    func updateAppearance(_ appearance: CanvasAppearance) {
        guard appearance != currentAppearance else { return }
        currentAppearance = appearance
        pendingAppearance = appearance
        backgroundView?.updateAppearance(appearance, traitCollection: traitCollection)
    }
    
    func updateTool(from toolState: ToolState) {
        guard let canvasView = canvasView else { return }
        
        let color = UIColor(hex: toolState.currentColorHex) ?? .black
        let pkTool = toolState.currentToolType.toPKTool(
            color: color,
            width: toolState.currentLineWidth
        )
        canvasView.tool = pkTool
        
        canvasView.isRulerActive = toolState.isRulerActive
        canvasView.drawingPolicy = toolState.fingerDrawingEnabled ? .anyInput : .pencilOnly
    }
    
    func updateDrawingIfNeeded(_ drawing: PKDrawing) {
        guard let canvasView = canvasView, canvasView.drawing != drawing else { return }
        canvasView.drawing = drawing
        lastKnownDrawing = drawing
    }
    
    // MARK: - Content Sizing
    
    /// Set the content size for the given mode and base size
    /// - For page mode: fixed size matching the page dimensions
    /// - For whiteboard mode: generous initial size (2000+) that auto-expands as user draws
    private func applyContentSize(for mode: CanvasMode, size: CGSize) {
        guard let canvasView = canvasView else { return }
        
        if mode == .page {
            canvasView.contentSize = size
            infiniteManager.setFixedSize(size)
        } else {
            let initialSize = CGSize(
                width: max(size.width, 2000),
                height: max(size.height, 2000)
            )
            canvasView.contentSize = initialSize
            infiniteManager = InfiniteCanvasManager(initialSize: initialSize)
        }
    }
    
    // MARK: - Canvas Expansion (Whiteboard Mode)
    
    /// Expand the canvas content in whiteboard mode based on drawing bounds.
    /// PKCanvasView auto-expands its contentSize slightly when strokes approach the edge,
    /// but we proactively expand by larger chunks (500pt via InfiniteCanvasManager)
    /// for a smoother infinite-canvas feel with fewer small resize events.
    /// The KVO on contentSize ensures the background view always matches.
    private func expandCanvasIfNeeded() {
        guard currentCanvasMode == .whiteboard, let canvasView = canvasView else { return }
        
        // Use drawing bounds with padding for a smooth expansion experience
        let drawingBounds = canvasView.drawing.bounds.insetBy(dx: -50, dy: -50)
        guard let newSize = infiniteManager.expandIfNeeded(drawingBounds: drawingBounds) else { return }
        
        let clamped = CGSize(
            width: min(newSize.width, infiniteManager.maximumSize.width),
            height: min(newSize.height, infiniteManager.maximumSize.height)
        )
        
        canvasView.contentSize = clamped
    }
}

// MARK: - PKCanvasViewDelegate

extension CanvasViewController: PKCanvasViewDelegate {
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let newDrawing = canvasView.drawing
        
        guard newDrawing != lastKnownDrawing else { return }
        lastKnownDrawing = newDrawing
        
        // In whiteboard mode, expand content if needed
        expandCanvasIfNeeded()
        
        delegate?.canvasDrawingDidChange(newDrawing)
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        delegate?.canvasDidBeginDrawing()
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        delegate?.canvasDidEndDrawing()
    }
}
