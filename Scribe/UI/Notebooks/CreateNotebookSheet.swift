// CreateNotebookSheet.swift
// Scribe — New notebook creation flow

import SwiftUI
import SwiftData

struct CreateNotebookSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationRouter.self) private var router
    
    @State private var title = ""
    @State private var selectedEmoji = "📓"
    @State private var selectedColor = "#5B7FFF"
    @State private var selectedTemplate: Template = .blank
    
    private let coverColors = [
        "#5B7FFF", "#FF6B6B", "#2ECC71", "#F39C12", "#9B59B6",
        "#1ABC9C", "#E74C3C", "#3498DB", "#E67E22", "#34495E",
        "#FF8ED4", "#00B894", "#6C5CE7", "#FDCB6E", "#636E72"
    ]
    
    private let emojis = [
        "📓", "📕", "📗", "📘", "📙", "📔",
        "📝", "✏️", "🎨", "💡", "🔬", "📐",
        "🎵", "🧮", "🌍", "⚛️", "🧬", "💻",
        "📊", "🎓", "✈️", "🏠", "🧘", "📸"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                emojiSection
                colorSection
                templateSection
                previewSection
            }
            .navigationTitle("New Notebook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createNotebook()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    @ViewBuilder
    private var titleSection: some View {
        SwiftUI.Section("Notebook Name") {
            TextField("Enter notebook title", text: $title)
                .font(.title3)
        }
    }
    
    @ViewBuilder
    private var emojiSection: some View {
        SwiftUI.Section("Icon") {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 8),
                spacing: 12
            ) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(
                            selectedEmoji == emoji
                                ? Color.accentColor.opacity(0.2)
                                : Color.clear,
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                        .overlay(
                            selectedEmoji == emoji
                                ? RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.accentColor, lineWidth: 2)
                                : nil
                        )
                        .onTapGesture {
                            selectedEmoji = emoji
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    private var colorSection: some View {
        SwiftUI.Section("Cover Color") {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 8),
                spacing: 12
            ) {
                ForEach(coverColors, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex) ?? .blue)
                        .frame(width: 36, height: 36)
                        .overlay(
                            selectedColor == hex
                                ? Circle().strokeBorder(.white, lineWidth: 3)
                                    .shadow(radius: 2)
                                : nil
                        )
                        .onTapGesture {
                            selectedColor = hex
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    private var templateSection: some View {
        Section("Default Page Template") {
            ForEach(Template.allBuiltIn, id: \.id) { (template: Template) in
                Button {
                    selectedTemplate = template
                } label: {
                    HStack {
                        Image(systemName: template.backgroundStyle.systemImage)
                            .frame(width: 24)
                            .foregroundColor(.primary)
                        
                        Text(template.name)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedTemplate.id == template.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var previewSection: some View {
        SwiftUI.Section("Preview") {
            HStack {
                Spacer()
                NotebookCoverView(notebook: previewNotebook)
                    .frame(width: 180)
                Spacer()
            }
            .listRowBackground(Color.clear)
        }
    }
    
    // MARK: - Preview Notebook
    
    private var previewNotebook: Notebook {
        let nb = Notebook(
            title: title.isEmpty ? "Untitled" : title,
            coverColor: selectedColor,
            emoji: selectedEmoji
        )
        return nb
    }
    
    // MARK: - Create
    
    private func createNotebook() {
        let service = NotebookService(modelContext: modelContext)
        let notebook = service.createNotebook(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            coverColor: selectedColor,
            emoji: selectedEmoji,
            template: selectedTemplate
        )
        
        router.navigateToNotebook(notebook)
        dismiss()
    }
}
