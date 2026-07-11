// ScribeUITests.swift
// Scribe — UI tests for core navigation flows

import XCTest

final class ScribeUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testSidebarDisplaysLibraryItems() {
        let sidebar = app.navigationBars["Scribe"]
        XCTAssertTrue(sidebar.waitForExistence(timeout: 5))
    }
    
    func testCreateNotebookFlow() {
        // Tap the create button
        let createButton = app.buttons["Create Notebook"]
        if createButton.waitForExistence(timeout: 5) {
            createButton.tap()
            
            // Check that the sheet appeared
            let titleField = app.textFields["Enter notebook title"]
            XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        }
    }
}
