// Constants.swift
// Scribe — App-wide constants

import Foundation

enum Constants {
    
    // MARK: - App
    
    static let appName = "Scribe"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // MARK: - Storage
    
    static let maxUndoStackSize = 200
    static let autoSaveIntervalSeconds: TimeInterval = 3.0
    static let thumbnailSize = CGSize(width: 200, height: 260)
    static let thumbnailJPEGQuality: CGFloat = 0.6
    
    // MARK: - Canvas
    
    static let defaultCanvasWidth: CGFloat = 768
    static let defaultCanvasHeight: CGFloat = 1024
    static let minimumZoomScale: CGFloat = 0.25
    static let maximumZoomScale: CGFloat = 8.0
    static let canvasExpansionMargin: CGFloat = 200
    static let canvasExpansionChunk: CGFloat = 500
    static let maxCanvasSize: CGFloat = 50_000
    
    // MARK: - Pencil
    
    static let defaultLineWidth: CGFloat = 3.0
    static let minimumLineWidth: CGFloat = 0.5
    static let maximumLineWidth: CGFloat = 30.0
    static let maxRecentColors = 12
    
    // MARK: - Performance
    
    static let maxTextureMemoryMB = 200
    static let tileSize: CGFloat = 256
}
