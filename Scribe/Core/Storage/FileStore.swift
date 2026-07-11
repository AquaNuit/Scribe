// FileStore.swift
// Scribe — File-based asset storage for images, audio, and other media

import Foundation
import UIKit

/// Manages file-based storage for media assets that are too large for SwiftData
actor FileStore {
    
    // MARK: - Directories
    
    private let baseDirectory: URL
    
    static let shared = FileStore()
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.baseDirectory = documentsPath.appendingPathComponent("ScribeAssets", isDirectory: true)
        
        // Ensure directories exist
        try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: pdfDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: exportsDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
    }
    
    var imagesDirectory: URL { baseDirectory.appendingPathComponent("Images", isDirectory: true) }
    var audioDirectory: URL { baseDirectory.appendingPathComponent("Audio", isDirectory: true) }
    var pdfDirectory: URL { baseDirectory.appendingPathComponent("PDFs", isDirectory: true) }
    var exportsDirectory: URL { baseDirectory.appendingPathComponent("Exports", isDirectory: true) }
    var thumbnailsDirectory: URL { baseDirectory.appendingPathComponent("Thumbnails", isDirectory: true) }
    
    // MARK: - Image Storage
    
    func saveImage(_ image: UIImage, fileName: String? = nil) throws -> String {
        let name = fileName ?? "\(UUID().uuidString).jpg"
        let url = imagesDirectory.appendingPathComponent(name)
        
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw FileStoreError.encodingFailed
        }
        
        try data.write(to: url)
        return name
    }
    
    func loadImage(fileName: String) throws -> UIImage {
        let url = imagesDirectory.appendingPathComponent(fileName)
        let data = try Data(contentsOf: url)
        guard let image = UIImage(data: data) else {
            throw FileStoreError.decodingFailed
        }
        return image
    }
    
    // MARK: - Data Storage
    
    func saveData(_ data: Data, to subdirectory: URL, fileName: String? = nil) throws -> String {
        let name = fileName ?? UUID().uuidString
        let url = subdirectory.appendingPathComponent(name)
        try data.write(to: url)
        return name
    }
    
    func loadData(from subdirectory: URL, fileName: String) throws -> Data {
        let url = subdirectory.appendingPathComponent(fileName)
        return try Data(contentsOf: url)
    }
    
    // MARK: - PDF Storage
    
    func savePDF(data: Data, fileName: String? = nil) throws -> String {
        let name = fileName ?? "\(UUID().uuidString).pdf"
        return try saveData(data, to: pdfDirectory, fileName: name)
    }
    
    func loadPDF(fileName: String) throws -> Data {
        return try loadData(from: pdfDirectory, fileName: fileName)
    }
    
    // MARK: - Deletion
    
    func deleteFile(in subdirectory: URL, fileName: String) throws {
        let url = subdirectory.appendingPathComponent(fileName)
        try FileManager.default.removeItem(at: url)
    }
    
    func deleteImage(fileName: String) throws {
        try deleteFile(in: imagesDirectory, fileName: fileName)
    }
    
    // MARK: - Disk Usage
    
    func totalDiskUsage() throws -> Int64 {
        return try directorySize(url: baseDirectory)
    }
    
    private func directorySize(url: URL) throws -> Int64 {
        let contents = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey]
        )
        
        var totalSize: Int64 = 0
        for item in contents {
            let resourceValues = try item.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
            if resourceValues.isDirectory == true {
                totalSize += try directorySize(url: item)
            } else {
                totalSize += Int64(resourceValues.fileSize ?? 0)
            }
        }
        return totalSize
    }
}

// MARK: - Errors

enum FileStoreError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "Failed to encode file data"
        case .decodingFailed: return "Failed to decode file data"
        case .fileNotFound: return "File not found"
        }
    }
}
