// OCRService.swift
// Scribe — On-device OCR using Apple Vision framework

import Foundation
import Vision
import UIKit
import OSLog

/// Recognizes handwritten text from images and drawings using Vision
final class OCRService: OCRServiceProtocol {
    
    // MARK: - AIServiceProtocol
    
    let serviceId = "com.scribe.ocr"
    
    var isAvailable: Bool {
        // Vision is available on all iOS 18+ devices
        return true
    }
    
    var isModelLoaded: Bool = true
    
    func loadModel() async throws {
        // Vision loads models on-demand, no explicit loading needed
        isModelLoaded = true
    }
    
    func unloadModel() {
        isModelLoaded = false
    }
    
    // MARK: - OCR
    
    func recognizeText(in image: UIImage) async throws -> [RecognizedText] {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let results = observations.compactMap { observation -> RecognizedText? in
                    guard let candidate = observation.topCandidates(1).first else { return nil }
                    
                    let boundingBox = observation.boundingBox
                    // Convert from Vision coordinates (bottom-left origin) to UIKit (top-left origin)
                    let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
                    let rect = CGRect(
                        x: boundingBox.origin.x * imageSize.width,
                        y: (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height,
                        width: boundingBox.width * imageSize.width,
                        height: boundingBox.height * imageSize.height
                    )
                    
                    return RecognizedText(
                        text: candidate.string,
                        confidence: candidate.confidence,
                        boundingBox: rect
                    )
                }
                
                continuation.resume(returning: results)
            }
            
            // Configure for handwriting
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func recognizeText(from drawingData: Data) async throws -> [RecognizedText] {
        // Convert PKDrawing data to image, then recognize
        guard let drawing = try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: NSData.self, from: drawingData
        ) else {
            throw OCRError.invalidDrawingData
        }
        
        // For now, return empty — actual PKDrawing deserialization needs PencilKit
        Logger.ai.info("OCR from drawing data not yet implemented")
        return []
    }
}

// MARK: - Errors

enum OCRError: LocalizedError {
    case invalidImage
    case invalidDrawingData
    case recognitionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage: return "The image could not be processed for text recognition"
        case .invalidDrawingData: return "The drawing data could not be read"
        case .recognitionFailed: return "Text recognition failed"
        }
    }
}
