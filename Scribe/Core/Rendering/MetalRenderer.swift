// MetalRenderer.swift
// Scribe — Metal rendering pipeline for high-performance canvas backgrounds
//
// This is the foundation for Metal-accelerated background rendering.
// v1 uses CoreGraphics via CanvasBackgroundView. 
// This will replace it in v2 for better zoom performance.

import Foundation
import Metal
import MetalKit
import OSLog

/// Metal rendering pipeline for tiled canvas backgrounds
final class MetalRenderer {
    
    // MARK: - Properties
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    private var pipelineState: MTLRenderPipelineState?
    private var textureCache: TextureCache?
    
    private(set) var isAvailable: Bool = false
    
    // MARK: - Init
    
    init() {
        setupMetal()
    }
    
    // MARK: - Setup
    
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            Logger.canvas.warning("Metal is not available on this device")
            isAvailable = false
            return
        }
        
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        self.textureCache = TextureCache(device: device)
        self.isAvailable = true
        
        Logger.canvas.info("Metal renderer initialized: \(device.name)")
    }
    
    // MARK: - Rendering (v2 — placeholder)
    
    /// Render background tiles for the visible region
    func renderBackground(
        in rect: CGRect,
        style: BackgroundStyle,
        zoomScale: CGFloat,
        isDarkMode: Bool
    ) {
        // v2 implementation will go here
        // This will render tiled backgrounds using Metal compute shaders
        // for smooth 60fps performance at any zoom level
    }
    
    /// Invalidate cached tiles when background style changes
    func invalidateCache() {
        textureCache?.clear()
    }
}

// MARK: - Texture Cache

/// GPU texture cache for tiled rendering
final class TextureCache {
    
    private let device: MTLDevice
    private var cache: [String: MTLTexture] = [:]
    private let maxCacheSizeMB: Int = 200
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    func texture(forKey key: String) -> MTLTexture? {
        return cache[key]
    }
    
    func store(_ texture: MTLTexture, forKey key: String) {
        cache[key] = texture
        
        // Evict if over budget
        if estimatedSizeMB > maxCacheSizeMB {
            evictOldest()
        }
    }
    
    func clear() {
        cache.removeAll()
    }
    
    private var estimatedSizeMB: Int {
        var total = 0
        for (_, texture) in cache {
            total += texture.width * texture.height * 4 // RGBA
        }
        return total / (1024 * 1024)
    }
    
    private func evictOldest() {
        // Simple eviction: remove half the cache
        let keysToRemove = Array(cache.keys.prefix(cache.count / 2))
        for key in keysToRemove {
            cache.removeValue(forKey: key)
        }
    }
}
