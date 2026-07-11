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
    private var modelContext: Any?
    
    // MARK: - Constants
    
    private let autoSaveInterval: TimeInterval = 3.0
    
    // MARK: - Load & Save
    
    func loadPage(_ page: Page) {
        self.currentPage = page
        self.drawing = page.drawing ?? PKDrawing()
        self.isDirty = false
        undoManager.clear()
        updateUndoState()
    }
    
    func handleDrawingChanged(_ newDrawing: PKDrawing) {
        let oldDrawing = self.drawing
        
        // Record for undo
        undoManager.record(
            undo: { [weak self] in
                self?.drawing = oldDrawing
                self?.isDirty = true
            },
            redo: { [weak self] in
                self?.drawing = newDrawing
                self?.isDirty = true
            }
        )
        
        self.drawing = newDrawing
        self.isDirty = true
        updateUndoState()
        scheduleAutoSave()
    }
    
    func save() {
        guard let page = currentPage, isDirty else { return }
        page.drawing = drawing
        page.generateThumbnail()
        isDirty = false
    }
    
    func undo() {
        undoManager.undo()
        updateUndoState()
    }
    
    func redo() {
        undoManager.redo()
        updateUndoState()
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
