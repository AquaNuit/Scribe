// SettingsView.swift
// Scribe — App settings screen

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ToolState.self) private var toolState
    
    @AppStorage("fingerDrawingEnabled") private var fingerDrawingEnabled = false
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = true
    @AppStorage("defaultBackground") private var defaultBackground = "blank"
    @AppStorage("defaultCanvasMode") private var defaultCanvasMode = "page"
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Apple Pencil
                
                SwiftUI.Section {
                    Toggle("Allow Finger Drawing", isOn: $fingerDrawingEnabled)
                    
                    NavigationLink {
                        PencilSettingsView()
                    } label: {
                        Label("Pencil Settings", systemImage: "applepencil")
                    }
                } header: {
                    Text("Apple Pencil")
                } footer: {
                    Text("When finger drawing is off, only Apple Pencil can draw. Fingers scroll and zoom.")
                }
                
                // MARK: - Canvas
                
                SwiftUI.Section("Canvas Defaults") {
                    Picker("Default Background", selection: $defaultBackground) {
                        ForEach(BackgroundStyle.allCases) { style in
                            Text(style.displayName).tag(style.rawValue)
                        }
                    }
                    
                    Picker("Default Mode", selection: $defaultCanvasMode) {
                        ForEach(CanvasMode.allCases) { mode in
                            Text(mode.displayName).tag(mode.rawValue)
                        }
                    }
                }
                
                // MARK: - Storage
                
                SwiftUI.Section {
                    Toggle("Auto-Save", isOn: $autoSaveEnabled)
                    
                    NavigationLink {
                        StorageInfoView()
                    } label: {
                        Label("Storage & Data", systemImage: "internaldrive")
                    }
                } header: {
                    Text("Storage")
                } footer: {
                    Text("Auto-save writes changes after 3 seconds of inactivity.")
                }
                
                // MARK: - About
                
                SwiftUI.Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(Constants.appVersion) (\(Constants.buildNumber))")
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink {
                        AboutView()
                    } label: {
                        Text("About Scribe")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onChange(of: fingerDrawingEnabled) { _, newValue in
                toolState.fingerDrawingEnabled = newValue
            }
        }
    }
}

// MARK: - Pencil Settings

struct PencilSettingsView: View {
    
    @AppStorage("pressureSensitivity") private var pressureSensitivity = 1.0
    @AppStorage("smoothingIntensity") private var smoothingIntensity = 0.5
    
    var body: some View {
        Form {
            SwiftUI.Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pressure Sensitivity")
                    Slider(value: $pressureSensitivity, in: 0.2...2.0, step: 0.1)
                    HStack {
                        Text("Light").font(.caption2).foregroundStyle(.secondary)
                        Spacer()
                        Text("Heavy").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stroke Smoothing")
                    Slider(value: $smoothingIntensity, in: 0...1.0, step: 0.1)
                    HStack {
                        Text("None").font(.caption2).foregroundStyle(.secondary)
                        Spacer()
                        Text("Maximum").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Input")
            } footer: {
                Text("Higher smoothing produces smoother lines but may feel less responsive.")
            }
            
            SwiftUI.Section("Pencil Squeeze") {
                Text("Pencil squeeze action can be configured in Settings → Apple Pencil on your iPad.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Pencil Settings")
    }
}

// MARK: - Storage Info

struct StorageInfoView: View {
    
    @State private var diskUsage: String = "Calculating..."
    
    var body: some View {
        Form {
            SwiftUI.Section("Disk Usage") {
                HStack {
                    Text("Total Storage Used")
                    Spacer()
                    Text(diskUsage)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Storage")
        .task {
            await calculateDiskUsage()
        }
    }
    
    private func calculateDiskUsage() async {
        do {
            let bytes = try await FileStore.shared.totalDiskUsage()
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB, .useGB]
            formatter.countStyle = .file
            diskUsage = formatter.string(fromByteCount: bytes)
        } catch {
            diskUsage = "Unable to calculate"
        }
    }
}

// MARK: - About

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("✍️")
                .font(.system(size: 72))
            
            VStack(spacing: 4) {
                Text("Scribe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                
                Text("Professional Note-Taking for iPad")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text("Version \(Constants.appVersion)")
                .font(.caption)
                .foregroundStyle(.tertiary)
            
            Spacer()
            
            Text("Built with ❤️ using SwiftUI & PencilKit")
                .font(.caption2)
                .foregroundStyle(.quaternary)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("About")
    }
}
