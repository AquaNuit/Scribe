// CanvasViewModel.swift
// Scribe — Canvas state management with undo/redo

import Foundation
import SwiftUI
import PencilKit
import Combine

@Observable
final class CanvasViewModel {
    
    // MARK: - State
    
    var currentPage: Page?
    var drawing: PKDrawing = PKDrawing()
    var isDrawing: Bool = false
    var isDirty: Bool = false
    var canUndo: Bool = false
    var canRedo: Bool = false
    
    /// Auto-save timer
    private var saveTimer: Timer?
    private var undoManager = ScribeUndoManager()
    
    /// Snapshot captured at the start of a stroke for per-stroke undo batching
    private var strokeStartDrawing: PKDrawing?
    
    // MARK: - Constants
    
    private let autoSaveInterval: TimeInterval = 3.0
    
    // MARK: - Load & Save
    
    func loadPage(_ page: Page) {
        self.currentPage = page
        self.drawing = page.drawing ?? PKDrawing()
        self.isDirty = false
        self.strokeStartDrawing = nil
        undoManager.clear()
        updateUndoState()
    }
    
    func handleDrawingChanged(_ newDrawing: PKDrawing) {
        // Update the drawing without recording undo on every incremental change
        self.drawing = newDrawing
        self.isDirty = true
        scheduleAutoSave()
    }
    
    /// Called when the user begins a stroke — captures the pre-stroke state
    func strokeBegan() {
        isDrawing = true
        strokeStartDrawing = drawing
    }
    
    /// Called when the user ends a stroke — records a single undo entry for the entire stroke
    func strokeEnded() {
        isDrawing = false
        
        guard let preStrokeDrawing = strokeStartDrawing else { return }
        let postStrokeDrawing = self.drawing
        
        // Only record if the drawing actually changed
        guard preStrokeDrawing != postStrokeDrawing else { return }
        
        undoManager.record(
            undo: { [weak self] in
                self?.drawing = preStrokeDrawing
                self?.isDirty = true
            },
            redo: { [weak self] in
                self?.drawing = postStrokeDrawing
                self?.isDirty = true
            }
        )
        
        strokeStartDrawing = nil
        updateUndoState()
    }
    
    func save() {
        guard let page = currentPage, isDirty else { return }
        page.drawing = drawing
        page.generateThumbnail()
        isDirty = false
    }
    
    func undo() {
        // If currently drawing, finish the stroke first
        if isDrawing {
            strokeEnded()
        }
        undoManager.undo()
        updateUndoState()
    }
    
    func redo() {
        // If currently drawing, finish the stroke first
        if isDrawing {
            strokeEnded()
        }
        undoManager.redo()
        updateUndoState()
    }
    
    // MARK: - Shape Insertion
    
    func insertShape(_ type: ScribeShapeType, colorHex: String, width: CGFloat, at bounds: CGRect) {
        let color = UIColor(hex: colorHex) ?? .black
        let shapeDrawing = ShapeInsertionService.createShapeDrawing(
            type: type,
            color: color,
            width: width,
            bounds: bounds
        )
        
        let preStrokeDrawing = self.drawing
        let postStrokeDrawing = self.drawing.appending(shapeDrawing)
        
        undoManager.record(
            undo: { [weak self] in
                self?.drawing = preStrokeDrawing
                self?.isDirty = true
            },
            redo: { [weak self] in
                self?.drawing = postStrokeDrawing
                self?.isDirty = true
            }
        )
        
        self.drawing = postStrokeDrawing
        self.isDirty = true
        updateUndoState()
        scheduleAutoSave()
    }
    
    // MARK: - Private
    
    private func updateUndoState() {
        canUndo = undoManager.canUndo
        canRedo = undoManager.canRedo
    }
    
    private func scheduleAutoSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(
            withTimeInterval: autoSaveInterval,
            repeats: false
        ) { [weak self] _ in
            self?.save()
        }
    }
    
    deinit {
        saveTimer?.invalidate()
    }
}

// MARK: - Undo Manager

/// Lightweight undo manager using closures (command pattern)
final class ScribeUndoManager {
    
    private struct Action {
        let undoClosure: () -> Void
        let redoClosure: () -> Void
    }
    
    private var undoStack: [Action] = []
    private var redoStack: [Action] = []
    
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
    
    func record(undo: @escaping () -> Void, redo: @escaping () -> Void) {
        undoStack.append(Action(undoClosure: undo, redoClosure: redo))
        redoStack.removeAll()
        
        // Limit stack size to prevent memory issues
        if undoStack.count > 200 {
            undoStack.removeFirst()
        }
    }
    
    func undo() {
        guard let action = undoStack.popLast() else { return }
        action.undoClosure()
        redoStack.append(action)
    }
    
    func redo() {
        guard let action = redoStack.popLast() else { return }
        action.redoClosure()
        undoStack.append(action)
    }
    
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
}
