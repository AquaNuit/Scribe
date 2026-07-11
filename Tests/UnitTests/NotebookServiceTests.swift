// NotebookServiceTests.swift
// Scribe — Unit tests for NotebookService

import XCTest
import SwiftData
@testable import Scribe

final class NotebookServiceTests: XCTestCase {
    
    var container: ModelContainer!
    var modelContext: ModelContext!
    var service: NotebookService!
    
    @MainActor
    override func setUp() async throws {
        container = try DataStore.createPreviewContainer()
        modelContext = container.mainContext
        service = NotebookService(modelContext: modelContext)
    }
    
    override func tearDown() {
        container = nil
        modelContext = nil
        service = nil
    }
    
    // MARK: - Create
    
    @MainActor
    func testCreateNotebook() throws {
        let notebook = service.createNotebook(title: "Test Notebook")
        
        XCTAssertEqual(notebook.title, "Test Notebook")
        XCTAssertEqual(notebook.coverColorHex, "#5B7FFF")
        XCTAssertFalse(notebook.isFavorite)
        XCTAssertFalse(notebook.isArchived)
        XCTAssertEqual(notebook.sortedSections.count, 1) // Default section
        XCTAssertEqual(notebook.pageCount, 1) // Default page
    }
    
    @MainActor
    func testCreateNotebookWithCustomOptions() throws {
        let notebook = service.createNotebook(
            title: "Custom",
            coverColor: "#FF6B6B",
            emoji: "🎨"
        )
        
        XCTAssertEqual(notebook.coverColorHex, "#FF6B6B")
        XCTAssertEqual(notebook.emoji, "🎨")
    }
    
    // MARK: - Read
    
    @MainActor
    func testFetchAllNotebooks() throws {
        let _ = service.createNotebook(title: "Notebook A")
        let _ = service.createNotebook(title: "Notebook B")
        
        let notebooks = try service.fetchAllNotebooks()
        XCTAssertEqual(notebooks.count, 2)
    }
    
    // MARK: - Update
    
    @MainActor
    func testToggleFavorite() throws {
        let notebook = service.createNotebook(title: "Fav Test")
        XCTAssertFalse(notebook.isFavorite)
        
        service.toggleFavorite(notebook)
        XCTAssertTrue(notebook.isFavorite)
        
        service.toggleFavorite(notebook)
        XCTAssertFalse(notebook.isFavorite)
    }
    
    @MainActor
    func testArchiveNotebook() throws {
        let notebook = service.createNotebook(title: "Archive Test")
        
        service.archiveNotebook(notebook)
        XCTAssertTrue(notebook.isArchived)
        
        let active = try service.fetchAllNotebooks(includeArchived: false)
        XCTAssertTrue(active.isEmpty)
        
        let all = try service.fetchAllNotebooks(includeArchived: true)
        XCTAssertEqual(all.count, 1)
    }
    
    // MARK: - Delete
    
    @MainActor
    func testDeleteNotebook() throws {
        let notebook = service.createNotebook(title: "Delete Test")
        
        service.deleteNotebook(notebook)
        
        let notebooks = try service.fetchAllNotebooks()
        XCTAssertTrue(notebooks.isEmpty)
    }
    
    // MARK: - Search
    
    @MainActor
    func testSearchNotebooks() throws {
        let _ = service.createNotebook(title: "Physics Notes")
        let _ = service.createNotebook(title: "Math Homework")
        let _ = service.createNotebook(title: "Physics Lab")
        
        let results = try service.searchNotebooks(query: "Physics")
        XCTAssertEqual(results.count, 2)
    }
}
