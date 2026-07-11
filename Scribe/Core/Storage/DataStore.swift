// DataStore.swift
// Scribe — SwiftData ModelContainer configuration

import Foundation
import SwiftData

/// Centralized data store configuration
enum DataStore {
    
    /// Create the production ModelContainer
    static func createContainer() throws -> ModelContainer {
        let schema = Schema([
            Notebook.self,
            Section.self,
            Page.self,
            Tag.self,
            MediaAttachment.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
    
    /// Create an in-memory container for previews and testing
    static func createPreviewContainer() throws -> ModelContainer {
        let schema = Schema([
            Notebook.self,
            Section.self,
            Page.self,
            Tag.self,
            MediaAttachment.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            allowsSave: true
        )
        
        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
    
    /// Create a preview container with sample data
    @MainActor
    static func createPreviewContainerWithSampleData() throws -> ModelContainer {
        let container = try createPreviewContainer()
        let context = container.mainContext
        
        // Create sample notebooks
        let notebook1 = Notebook(title: "Physics Notes", coverColor: "#5B7FFF", emoji: "⚛️")
        let notebook2 = Notebook(title: "Design Sketches", coverColor: "#FF6B6B", emoji: "🎨")
        let notebook3 = Notebook(title: "Meeting Notes", coverColor: "#2ECC71", emoji: "📝")
        
        let section1 = Section(title: "Chapter 1: Mechanics", sortOrder: 0)
        let section2 = Section(title: "Chapter 2: Thermodynamics", sortOrder: 1)
        
        let page1 = Page(title: "Newton's Laws", backgroundStyle: .lined)
        let page2 = Page(title: "Free Body Diagrams", backgroundStyle: .grid)
        let page3 = Page(title: "Conservation of Energy", backgroundStyle: .blank)
        
        section1.pages = [page1, page2]
        section2.pages = [page3]
        notebook1.sections = [section1, section2]
        
        section1.notebook = notebook1
        section2.notebook = notebook1
        page1.section = section1
        page2.section = section1
        page3.section = section2
        
        let sketchSection = Section(title: "UI Concepts", sortOrder: 0)
        let sketchPage = Page(title: "App Layout", backgroundStyle: .dotGrid)
        sketchSection.pages = [sketchPage]
        notebook2.sections = [sketchSection]
        sketchSection.notebook = notebook2
        sketchPage.section = sketchSection
        
        let meetingSection = Section(title: "July 2026", sortOrder: 0)
        let meetingPage = Page(title: "Sprint Planning", backgroundStyle: .cornell)
        meetingSection.pages = [meetingPage]
        notebook3.sections = [meetingSection]
        meetingSection.notebook = notebook3
        meetingPage.section = meetingSection
        
        notebook2.isFavorite = true
        
        context.insert(notebook1)
        context.insert(notebook2)
        context.insert(notebook3)
        
        try context.save()
        
        return container
    }
}
