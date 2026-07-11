// PerformanceMonitor.swift
// Scribe — Lightweight performance monitoring for canvas and rendering

import Foundation
import OSLog
import QuartzCore

/// Tracks frame timings, memory usage, and drawing performance metrics
final class PerformanceMonitor {
    
    // MARK: - Singleton
    
    static let shared = PerformanceMonitor()
    
    // MARK: - Properties
    
    private var frameTimestamps: [CFTimeInterval] = []
    private var lastFrameTime: CFTimeInterval = 0
    private var strokeStartTime: CFTimeInterval = 0
    
    /// Current frames per second (rolling average)
    var currentFPS: Double {
        guard frameTimestamps.count > 1 else { return 0 }
        let elapsed = frameTimestamps.last! - frameTimestamps.first!
        guard elapsed > 0 else { return 0 }
        return Double(frameTimestamps.count - 1) / elapsed
    }
    
    /// Memory usage in MB
    var memoryUsageMB: Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { ptr in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), ptr, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            return Double(info.resident_size) / (1024 * 1024)
        }
        return 0
    }
    
    // MARK: - Frame Tracking
    
    func recordFrame() {
        let now = CACurrentMediaTime()
        frameTimestamps.append(now)
        
        // Keep only last 60 timestamps
        if frameTimestamps.count > 60 {
            frameTimestamps.removeFirst(frameTimestamps.count - 60)
        }
    }
    
    // MARK: - Stroke Timing
    
    func strokeBegan() {
        strokeStartTime = CACurrentMediaTime()
    }
    
    func strokeEnded() -> TimeInterval {
        return CACurrentMediaTime() - strokeStartTime
    }
    
    // MARK: - Logging
    
    func logPerformanceSnapshot() {
        Logger.performance.info("""
            Performance Snapshot:
            FPS: \(String(format: "%.1f", self.currentFPS))
            Memory: \(String(format: "%.1f", self.memoryUsageMB))MB
            """)
    }
    
    // MARK: - Measurement
    
    /// Measure execution time of a block
    @discardableResult
    static func measure<T>(_ label: String, block: () -> T) -> T {
        let start = CACurrentMediaTime()
        let result = block()
        let elapsed = (CACurrentMediaTime() - start) * 1000
        Logger.performance.info("\(label): \(String(format: "%.2f", elapsed))ms")
        return result
    }
    
    /// Measure execution time of an async block
    @discardableResult
    static func measureAsync<T>(_ label: String, block: () async throws -> T) async rethrows -> T {
        let start = CACurrentMediaTime()
        let result = try await block()
        let elapsed = (CACurrentMediaTime() - start) * 1000
        Logger.performance.info("\(label): \(String(format: "%.2f", elapsed))ms")
        return result
    }
}
