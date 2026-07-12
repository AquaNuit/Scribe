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
    private(set) var configuredMode: CanvasMode = .page
    private var currentAppearance: CanvasAppearance = .system
    private var lastKnownDrawing: PKDrawing?
    
    /// Callback so the SwiftUI layer can match the canvas background color
    var onBackgroundColorResolved: ((UIColor) -> Void)?
    
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
        view.backgroundColor = .systemBackground
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
        syncBackgroundFrame()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            backgroundView?.updateAppearance(currentAppearance, traitCollection: traitCollection)
            notifyBackgroundColor()
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
        
        // Observe content size changes to keep background in sync
        contentSizeObservation = canvasView.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
            guard let self = self else { return }
            self.syncBackgroundFrame()
        }
    }
    
    private func setupBackground() {
        backgroundView = CanvasBackgroundView(frame: .zero)
        backgroundView.contentMode = .redraw
        
        // Insert background behind the canvas drawing layer.
        // We manually manage the frame instead of using constraints,
        // because we need it to exactly match contentSize at all times.
        canvasView.insertSubview(backgroundView, at: 0)
    }
    
    /// Keep the background view frame exactly equal to the canvas content size.
    /// This ensures the background fills the entire drawable area and scrolls/zooms
    /// with the drawing content as a single unit.
    private func syncBackgroundFrame() {
        guard let canvasView = canvasView, let backgroundView = backgroundView else { return }
        let contentSize = canvasView.contentSize
        let newFrame = CGRect(origin: .zero, size: contentSize)
        if backgroundView.frame != newFrame {
            backgroundView.frame = newFrame
            backgroundView.setNeedsDisplay()
        }
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
        pendingDrawing = drawing
        pendingCanvasSize = canvasSize
        pendingTemplate = template
        pendingCanvasMode = canvasMode
        pendingAppearance = appearance
        
        currentTemplate = template
        configuredMode = canvasMode
        currentAppearance = appearance
        currentCanvasSize = canvasSize
        
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
        let mode = pendingCanvasMode ?? configuredMode
        let appearance = pendingAppearance ?? currentAppearance
        
        currentCanvasSize = size
        currentTemplate = template
        configuredMode = mode
        currentAppearance = appearance
        
        applyContentSize(for: mode, size: size)
        syncBackgroundFrame()
        
        backgroundView.configure(
            with: template,
            appearance: appearance,
            traitCollection: traitCollection
        )
        
        notifyBackgroundColor()
        
        // Clear pending
        pendingDrawing = nil
        pendingCanvasSize = nil
        pendingTemplate = nil
        pendingCanvasMode = nil
        pendingAppearance = nil
    }
    
    // MARK: - Live Updates (called from updateUIViewController)
    
    func updateTemplate(_ template: Template) {
        guard let backgroundView = backgroundView else { return }
        currentTemplate = template
        backgroundView.configure(
            with: template,
            appearance: currentAppearance,
            traitCollection: traitCollection
        )
        notifyBackgroundColor()
    }
    
    func updateCanvasMode(_ mode: CanvasMode, canvasSize: CGSize) {
        configuredMode = mode
        currentCanvasSize = canvasSize
        
        guard canvasView != nil else { return }
        
        applyContentSize(for: mode, size: canvasSize)
        syncBackgroundFrame()
    }
    
    func updateAppearance(_ appearance: CanvasAppearance) {
        guard appearance != currentAppearance else { return }
        currentAppearance = appearance
        backgroundView?.updateAppearance(appearance, traitCollection: traitCollection)
        notifyBackgroundColor()
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
    
    // MARK: - Background Color Notification
    
    /// Resolves the current background color and notifies SwiftUI so the
    /// editor view's ZStack background can match (preventing black borders).
    private func notifyBackgroundColor() {
        let color = backgroundView?.resolvedBackgroundColor ?? .systemBackground
        onBackgroundColorResolved?(color)
    }
    
    // MARK: - Content Sizing
    
    private func applyContentSize(for mode: CanvasMode, size: CGSize) {
        guard let canvasView = canvasView else { return }
        
        if mode == .page {
            canvasView.contentSize = size
            infiniteManager.setFixedSize(size)
        } else {
            let initialSize = CGSize(
                width: max(size.width, 3000),
                height: max(size.height, 3000)
            )
            canvasView.contentSize = initialSize
            infiniteManager = InfiniteCanvasManager(initialSize: initialSize)
        }
    }
    
    // MARK: - Canvas Expansion (Whiteboard Mode)
    
    private func expandCanvasIfNeeded() {
        guard configuredMode == .whiteboard, let canvasView = canvasView else { return }
        
        let drawingBounds = canvasView.drawing.bounds.insetBy(dx: -100, dy: -100)
        guard let newSize = infiniteManager.expandIfNeeded(drawingBounds: drawingBounds) else { return }
        
        let clamped = CGSize(
            width: min(newSize.width, infiniteManager.maximumSize.width),
            height: min(newSize.height, infiniteManager.maximumSize.height)
        )
        
        canvasView.contentSize = clamped
        syncBackgroundFrame()
    }
}

// MARK: - PKCanvasViewDelegate

extension CanvasViewController: PKCanvasViewDelegate {
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let newDrawing = canvasView.drawing
        
        guard newDrawing != lastKnownDrawing else { return }
        lastKnownDrawing = newDrawing
        
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
