// SortOrder.swift
// Scribe — Sort order options

import Foundation

/// Notebook sorting options — prefixed to avoid conflict with Foundation.SortOrder
enum NotebookSortOrder: String, Codable, CaseIterable, Identifiable {
    case dateModified = "dateModified"
    case dateCreated = "dateCreated"
    case title = "title"
    case manual = "manual"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .dateModified: return "Date Modified"
        case .dateCreated: return "Date Created"
        case .title: return "Title"
        case .manual: return "Manual"
        }
    }
    
    var systemImage: String {
        switch self {
        case .dateModified: return "clock.arrow.circlepath"
        case .dateCreated: return "calendar"
        case .title: return "textformat"
        case .manual: return "hand.draw"
        }
    }
}

enum MediaType: String, Codable, CaseIterable {
    case image = "image"
    case audio = "audio"
    case video = "video"
    case sticker = "sticker"
    case textBox = "textBox"
    case shape = "shape"
    case link = "link"
    case equation = "equation"
    
    var displayName: String {
        switch self {
        case .image: return "Image"
        case .audio: return "Audio"
        case .video: return "Video"
        case .sticker: return "Sticker"
        case .textBox: return "Text"
        case .shape: return "Shape"
        case .link: return "Link"
        case .equation: return "Equation"
        }
    }
}
