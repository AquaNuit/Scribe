// Logger.swift
// Scribe — Unified logging using os.Logger

import OSLog

extension Logger {
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.scribe.app"
    
    // MARK: - Category Loggers
    
    /// Canvas and drawing operations
    static let canvas = Logger(subsystem: subsystem, category: "Canvas")
    
    /// Apple Pencil input processing
    static let pencil = Logger(subsystem: subsystem, category: "Pencil")
    
    /// Data persistence and storage
    static let storage = Logger(subsystem: subsystem, category: "Storage")
    
    /// Cloud sync operations
    static let sync = Logger(subsystem: subsystem, category: "Sync")
    
    /// PDF import/export
    static let pdf = Logger(subsystem: subsystem, category: "PDF")
    
    /// Search and indexing
    static let search = Logger(subsystem: subsystem, category: "Search")
    
    /// AI and ML operations
    static let ai = Logger(subsystem: subsystem, category: "AI")
    
    /// General app lifecycle
    static let app = Logger(subsystem: subsystem, category: "App")
    
    /// Performance monitoring
    static let performance = Logger(subsystem: subsystem, category: "Performance")
}
