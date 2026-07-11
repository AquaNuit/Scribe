// ScribeApp.swift
// Scribe — Production-Grade iPad Note-Taking Application
// App entry point with SwiftData ModelContainer configuration

import SwiftUI
import SwiftData

@main
struct ScribeApp: App {
    
    // MARK: - State
    
    @State private var navigationRouter = NavigationRouter()
    @State private var toolState = ToolState()
    
    // MARK: - Model Container
    
    private let modelContainer: ModelContainer = {
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
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(navigationRouter)
                .environment(toolState)
        }
        .modelContainer(modelContainer)
    }
}
