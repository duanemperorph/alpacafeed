//
//  Embed.swift
//  AlpacaList
//
//  Embedded media and content for Bluesky posts
//

import Foundation

/// Represents embedded content in a post (images, videos, links, quotes)
enum Embed: Codable, Equatable {
    case images([ImageEmbed])
    case video(VideoEmbed)
    case external(ExternalEmbed)
    case record(RecordEmbed)           // Quote post
    case recordWithMedia(RecordEmbed, MediaEmbed)  // Quote with media
    
    /// Image embed (up to 4 images per post)
    struct ImageEmbed: Codable, Equatable, Identifiable {
        let id = UUID()
        let thumb: String?      // Thumbnail URL
        let fullsize: String    // Full image URL
        let alt: String?        // Alt text for accessibility
        let aspectRatio: AspectRatio?
        
        enum CodingKeys: String, CodingKey {
            case thumb, fullsize, alt, aspectRatio
        }
    }
    
    /// Video embed
    struct VideoEmbed: Codable, Equatable {
        let thumbnail: String?  // Thumbnail URL
        let playlist: String    // Video playlist URL (m3u8)
        let alt: String?        // Alt text/caption
        let aspectRatio: AspectRatio?
    }
    
    /// External link preview
    struct ExternalEmbed: Codable, Equatable {
        let uri: String         // Target URL
        let title: String
        let description: String
        let thumb: String?      // Preview thumbnail
    }
    
    /// Quoted post reference
    struct RecordEmbed: Codable, Equatable {
        let uri: String         // at:// URI of quoted post
        let cid: String         // Content identifier
    }
    
    /// Media embed (for recordWithMedia case)
    enum MediaEmbed: Codable, Equatable {
        case images([ImageEmbed])
        case video(VideoEmbed)
    }
    
    struct AspectRatio: Codable, Equatable {
        let width: Int
        let height: Int
    }
    
    // MARK: - Codable implementation
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case images, video, external, record, media
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "app.bsky.embed.images":
            let images = try container.decode([ImageEmbed].self, forKey: .images)
            self = .images(images)
        case "app.bsky.embed.video":
            let video = try container.decode(VideoEmbed.self, forKey: .video)
            self = .video(video)
        case "app.bsky.embed.external":
            let external = try container.decode(ExternalEmbed.self, forKey: .external)
            self = .external(external)
        case "app.bsky.embed.record":
            let record = try container.decode(RecordEmbed.self, forKey: .record)
            self = .record(record)
        case "app.bsky.embed.recordWithMedia":
            let record = try container.decode(RecordEmbed.self, forKey: .record)
            let media = try container.decode(MediaEmbed.self, forKey: .media)
            self = .recordWithMedia(record, media)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown embed type: \(type)"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .images(let images):
            try container.encode("app.bsky.embed.images", forKey: .type)
            try container.encode(images, forKey: .images)
        case .video(let video):
            try container.encode("app.bsky.embed.video", forKey: .type)
            try container.encode(video, forKey: .video)
        case .external(let external):
            try container.encode("app.bsky.embed.external", forKey: .type)
            try container.encode(external, forKey: .external)
        case .record(let record):
            try container.encode("app.bsky.embed.record", forKey: .type)
            try container.encode(record, forKey: .record)
        case .recordWithMedia(let record, let media):
            try container.encode("app.bsky.embed.recordWithMedia", forKey: .type)
            try container.encode(record, forKey: .record)
            try container.encode(media, forKey: .media)
        }
    }
    
    // MARK: - Convenience properties
    
    var hasImages: Bool {
        switch self {
        case .images: return true
        case .recordWithMedia(_, .images): return true
        default: return false
        }
    }
    
    var hasVideo: Bool {
        switch self {
        case .video: return true
        case .recordWithMedia(_, .video): return true
        default: return false
        }
    }
    
    var isQuotePost: Bool {
        switch self {
        case .record, .recordWithMedia: return true
        default: return false
        }
    }
}

