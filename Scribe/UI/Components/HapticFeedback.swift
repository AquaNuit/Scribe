// HapticFeedback.swift
// Scribe — Centralized haptic feedback utilities

import UIKit

/// Provides consistent haptic feedback throughout the app
enum HapticFeedback {
    
    /// Light tap — for selections, toggles
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium tap — for tool changes, snapping
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy tap — for significant actions
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Success notification — for completed actions
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Error notification
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// Selection changed — for picker/list selection
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
