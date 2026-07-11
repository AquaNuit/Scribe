// NavigationRouter.swift
// Scribe — Centralized navigation state management

import SwiftUI

@Observable
final class NavigationRouter {
    
    // MARK: - Navigation State
    
    /// Currently selected sidebar item
    var selectedSidebarItem: SidebarItem = .allNotebooks
    
    /// Currently selected notebook
    var selectedNotebook: Notebook?
    
    /// Currently selected page for editing
    var selectedPage: Page?
    
    /// Whether the canvas editor is presented
    var isCanvasPresented: Bool = false
    
    /// Split view column visibility
    var columnVisibility: NavigationSplitViewVisibility = .all
    
    /// Search query
    var searchQuery: String = ""
    
    /// Whether settings sheet is shown
    var showSettings: Bool = false
    
    /// Whether create notebook sheet is shown
    var showCreateNotebook: Bool = false
    
    // MARK: - Sidebar Items
    
    enum SidebarItem: Hashable {
        case allNotebooks
        case favorites
        case recentlyModified
        case tags
        case archive
        case trash
    }
    
    // MARK: - Navigation Actions
    
    func navigateToNotebook(_ notebook: Notebook) {
        selectedNotebook = notebook
        selectedPage = nil
    }
    
    func navigateToPage(_ page: Page) {
        selectedPage = page
        isCanvasPresented = true
    }
    
    func navigateToPage(_ page: Page, in notebook: Notebook) {
        selectedNotebook = notebook
        selectedPage = page
        isCanvasPresented = true
    }
    
    func dismissCanvas() {
        isCanvasPresented = false
        selectedPage = nil
    }
    
    func ensureDefaults() {
        if selectedSidebarItem == .allNotebooks && selectedNotebook == nil {
            // Will be populated by the content view
        }
    }
}
