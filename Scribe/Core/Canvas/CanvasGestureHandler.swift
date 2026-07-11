// CanvasGestureHandler.swift
// Scribe — Custom gesture recognition for canvas interactions

import UIKit

/// Handles multi-touch gestures on the canvas (two-finger undo, three-finger paste, etc.)
final class CanvasGestureHandler: NSObject {
    
    // MARK: - Callbacks
    
    var onTwoFingerUndo: (() -> Void)?
    var onThreeFingerSwipeLeft: (() -> Void)?  // Redo
    var onThreeFingerSwipeRight: (() -> Void)? // Undo
    var onPinchToZoom: ((CGFloat) -> Void)?
    
    // MARK: - Setup
    
    func attachGestures(to view: UIView) {
        // Two-finger tap for undo
        let twoFingerTap = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerTap(_:)))
        twoFingerTap.numberOfTouchesRequired = 2
        twoFingerTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(twoFingerTap)
        
        // Three-finger swipe left for redo
        let threeFingerSwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleThreeFingerSwipeLeft(_:)))
        threeFingerSwipeLeft.numberOfTouchesRequired = 3
        threeFingerSwipeLeft.direction = .left
        view.addGestureRecognizer(threeFingerSwipeLeft)
        
        // Three-finger swipe right for undo
        let threeFingerSwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleThreeFingerSwipeRight(_:)))
        threeFingerSwipeRight.numberOfTouchesRequired = 3
        threeFingerSwipeRight.direction = .right
        view.addGestureRecognizer(threeFingerSwipeRight)
    }
    
    // MARK: - Handlers
    
    @objc private func handleTwoFingerTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .recognized {
            onTwoFingerUndo?()
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    @objc private func handleThreeFingerSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .recognized {
            onThreeFingerSwipeLeft?()
        }
    }
    
    @objc private func handleThreeFingerSwipeRight(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .recognized {
            onThreeFingerSwipeRight?()
        }
    }
}
