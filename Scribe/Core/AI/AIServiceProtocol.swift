// AIServiceProtocol.swift
// Scribe — Modular AI service interface for future ML features

import Foundation
import UIKit

// MARK: - Core Protocol

/// All AI services conform to this protocol for uniform management
protocol AIServiceProtocol {
    /// Service identifier
    var serviceId: String { get }
    
    /// Whether the service is available on this device
    var isAvailable: Bool { get }
    
    /// Whether the required ML model is loaded
    var isModelLoaded: Bool { get }
    
    /// Load the ML model into memory
    func loadModel() async throws
    
    /// Unload the ML model to free memory
    func unloadModel()
}

// MARK: - OCR Protocol

protocol OCRServiceProtocol: AIServiceProtocol {
    /// Recognize text from an image
    func recognizeText(in image: UIImage) async throws -> [RecognizedText]
    
    /// Recognize text from drawing data
    func recognizeText(from drawingData: Data) async throws -> [RecognizedText]
}

struct RecognizedText: Identifiable, Sendable {
    let id = UUID()
    let text: String
    let confidence: Float
    let boundingBox: CGRect
}

// MARK: - Shape Recognition Protocol

protocol ShapeRecognitionServiceProtocol: AIServiceProtocol {
    /// Detect shapes in a drawing
    func recognizeShapes(from drawingData: Data) async throws -> [RecognizedShape]
    
    /// Clean up / beautify a detected shape
    func beautifyShape(_ shape: RecognizedShape) async throws -> Data
}

struct RecognizedShape: Identifiable, Sendable {
    let id = UUID()
    let shapeType: ShapeType
    let confidence: Float
    let boundingBox: CGRect
    let controlPoints: [CGPoint]
    
    enum ShapeType: String, Sendable {
        case line, circle, rectangle, triangle, arrow, star, ellipse
    }
}

// MARK: - Math Solver Protocol

protocol MathSolverServiceProtocol: AIServiceProtocol {
    /// Solve a recognized mathematical expression
    func solve(expression: String) async throws -> MathResult
}

struct MathResult: Sendable {
    let input: String
    let result: String
    let steps: [String]
}

// MARK: - Summarization Protocol

protocol SummarizationServiceProtocol: AIServiceProtocol {
    /// Summarize text content
    func summarize(text: String, maxLength: Int) async throws -> String
}

// MARK: - AI Service Manager

/// Manages loading and lifecycle of all AI services
@Observable
final class AIServiceManager {
    
    var services: [String: any AIServiceProtocol] = [:]
    
    func register(_ service: any AIServiceProtocol) {
        services[service.serviceId] = service
    }
    
    func service<T: AIServiceProtocol>(ofType type: T.Type) -> T? {
        services.values.first(where: { $0 is T }) as? T
    }
    
    func loadAll() async {
        for (_, service) in services {
            if service.isAvailable {
                try? await service.loadModel()
            }
        }
    }
    
    func unloadAll() {
        for (_, service) in services {
            service.unloadModel()
        }
    }
}
