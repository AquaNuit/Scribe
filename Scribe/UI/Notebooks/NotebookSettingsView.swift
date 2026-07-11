// NotebookSettingsView.swift
// Scribe — Notebook-level settings (rename, change cover, manage sections, export)

import SwiftUI
import SwiftData

struct NotebookSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let notebook: Notebook
    
    @State private var title: String = ""
    @State private var selectedColor: String = "#5B7FFF"
    @State private var selectedEmoji: String = "📓"
    @State private var showDeleteConfirmation = false
    
    private let coverColors = [
        "#5B7FFF", "#FF6B6B", "#2ECC71", "#F39C12", "#9B59B6",
        "#1ABC9C", "#E74C3C", "#3498DB", "#E67E22", "#34495E",
        "#FF8ED4", "#00B894", "#6C5CE7", "#FDCB6E", "#636E72"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Title
                SwiftUI.Section("Notebook Name") {
                    TextField("Title", text: $title)
                        .font(.title3)
                }
                
                // Cover Color
                SwiftUI.Section("Cover Color") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 8),
                        spacing: 10
                    ) {
                        ForEach(coverColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex) ?? .blue)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    selectedColor == hex
                                    ? Circle().strokeBorder(.white, lineWidth: 3)
                                        .shadow(radius: 2)
                                    : nil
                                )
                                .onTapGesture { selectedColor = hex }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Info
                SwiftUI.Section("Info") {
                    HStack {
                        Text("Sections")
                        Spacer()
                        Text("\(notebook.sortedSections.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Pages")
                        Spacer()
                        Text("\(notebook.pageCount)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(notebook.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Modified")
                        Spacer()
                        Text(notebook.modifiedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Actions
                SwiftUI.Section("Actions") {
                    Button {
                        let service = NotebookService(modelContext: modelContext)
                        service.toggleFavorite(notebook)
                    } label: {
                        Label(
                            notebook.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: notebook.isFavorite ? "heart.slash" : "heart"
                        )
                    }
                    
                    Button {
                        let service = NotebookService(modelContext: modelContext)
                        if notebook.isArchived {
                            service.unarchiveNotebook(notebook)
                        } else {
                            service.archiveNotebook(notebook)
                        }
                    } label: {
                        Label(
                            notebook.isArchived ? "Unarchive" : "Archive",
                            systemImage: notebook.isArchived ? "tray.and.arrow.up" : "archivebox"
                        )
                    }
                }
                
                // Danger Zone
                SwiftUI.Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Notebook", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Notebook Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                title = notebook.title
                selectedColor = notebook.coverColorHex
                selectedEmoji = notebook.emoji ?? "📓"
            }
            .alert("Delete Notebook?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    let service = NotebookService(modelContext: modelContext)
                    service.deleteNotebook(notebook)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete \"\(notebook.title)\" and all its pages. This cannot be undone.")
            }
        }
    }
    
    private func saveChanges() {
        let service = NotebookService(modelContext: modelContext)
        service.updateNotebook(
            notebook,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            coverColor: selectedColor,
            emoji: selectedEmoji
        )
    }
}
