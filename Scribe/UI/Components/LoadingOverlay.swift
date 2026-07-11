// LoadingOverlay.swift
// Scribe — Full-screen loading overlay with progress

import SwiftUI

struct LoadingOverlay: View {
    
    let message: String
    var progress: Double? = nil
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if let progress = progress {
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .tint(.white)
                } else {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
                
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                if let progress = progress {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .monospacedDigit()
                }
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
        .transition(.opacity)
    }
}

// MARK: - View Modifier

struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool
    let message: String
    var progress: Double? = nil
    
    func body(content: Content) -> some View {
        content.overlay {
            if isLoading {
                LoadingOverlay(message: message, progress: progress)
            }
        }
    }
}

extension View {
    func loadingOverlay(isLoading: Bool, message: String = "Loading...", progress: Double? = nil) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading, message: message, progress: progress))
    }
}

#Preview {
    Color.blue
        .ignoresSafeArea()
        .loadingOverlay(isLoading: true, message: "Importing PDF...", progress: 0.65)
}
