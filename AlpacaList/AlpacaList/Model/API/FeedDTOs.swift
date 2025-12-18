//
//  FeedDTOs.swift
//  AlpacaList
//
//  Data Transfer Objects for Bluesky API responses
//

import Foundation

// MARK: - Response Types (DTOs)

/// Response from getTimeline / getFeed
struct TimelineResponse: Decodable {
    let feed: [FeedItemDTO]
    let cursor: String?
}

/// A post in the feed with viewer context
struct FeedItemDTO: Decodable {
    let post: PostDTO
    let reply: ReplyContextDTO?
    let reason: FeedReasonDTO?
}

/// Post data transfer object with full data
struct PostDTO: Decodable {
    let uri: String
    let cid: String
    let author: AuthorDTO
    let record: PostRecordDTO
    let embed: EmbedDTO?
    let replyCount: Int?
    let repostCount: Int?
    let likeCount: Int?
    let indexedAt: String
    let viewer: ViewerStateDTO?
}

/// Author data transfer object
struct AuthorDTO: Decodable {
    let did: String
    let handle: String
    let displayName: String?
    let avatar: String?
}

/// Post record content
struct PostRecordDTO: Decodable {
    let text: String
    let createdAt: String
    // facets, reply, embed - TODO
}

/// Viewer's relationship to the post
struct ViewerStateDTO: Decodable {
    let like: String?      // URI of viewer's like record
    let repost: String?    // URI of viewer's repost record
}

/// Reply context (parent/root post info)
struct ReplyContextDTO: Decodable {
    let root: PostDTO?
    let parent: PostDTO?
}

/// Reason for post appearing in feed (e.g., repost)
struct FeedReasonDTO: Decodable {
    let type: String?
    let by: AuthorDTO?
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case by
    }
}

/// Response from getPostThread
struct ThreadResponse: Decodable {
    let thread: ThreadItemDTO
}

/// Thread item with post, parents, and replies
/// Uses class to allow recursive references
final class ThreadItemDTO: Decodable {
    let post: PostDTO
    let parent: ThreadParentDTO?
    let replies: [ThreadReplyDTO]?
}

/// Parent in thread (can be post or blocked/not found)
enum ThreadParentDTO: Decodable {
    case post(ThreadItemDTO)
    case notFound
    case blocked
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        
        switch type {
        case "app.bsky.feed.defs#threadViewPost":
            self = .post(try ThreadItemDTO(from: decoder))
        case "app.bsky.feed.defs#notFoundPost":
            self = .notFound
        case "app.bsky.feed.defs#blockedPost":
            self = .blocked
        default:
            self = .post(try ThreadItemDTO(from: decoder))
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
    }
}

/// Reply in thread
enum ThreadReplyDTO: Decodable {
    case post(ThreadItemDTO)
    case notFound
    case blocked
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        
        switch type {
        case "app.bsky.feed.defs#threadViewPost":
            self = .post(try ThreadItemDTO(from: decoder))
        case "app.bsky.feed.defs#notFoundPost":
            self = .notFound
        case "app.bsky.feed.defs#blockedPost":
            self = .blocked
        default:
            self = .post(try ThreadItemDTO(from: decoder))
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
    }
}

/// Response from createRecord
struct CreateRecordResponse: Decodable {
    let uri: String
    let cid: String
}

// MARK: - Embed DTOs

/// Polymorphic embed type - handles images, video, external links, quotes
enum EmbedDTO: Decodable {
    case images(EmbedImagesDTO)
    case video(EmbedVideoDTO)
    case external(EmbedExternalDTO)
    case record(EmbedRecordDTO)
    case recordWithMedia(EmbedRecordWithMediaDTO)
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        
        switch type {
        case "app.bsky.embed.images#view":
            self = .images(try EmbedImagesDTO(from: decoder))
        case "app.bsky.embed.video#view":
            self = .video(try EmbedVideoDTO(from: decoder))
        case "app.bsky.embed.external#view":
            self = .external(try EmbedExternalDTO(from: decoder))
        case "app.bsky.embed.record#view":
            self = .record(try EmbedRecordDTO(from: decoder))
        case "app.bsky.embed.recordWithMedia#view":
            self = .recordWithMedia(try EmbedRecordWithMediaDTO(from: decoder))
        default:
            self = .unknown
        }
    }
}

/// Images embed DTO
struct EmbedImagesDTO: Decodable {
    let images: [EmbedImageDTO]
}

/// Single image in embed
struct EmbedImageDTO: Decodable {
    let thumb: String
    let fullsize: String
    let alt: String
    let aspectRatio: AspectRatioDTO?
}

/// Aspect ratio for images/videos
struct AspectRatioDTO: Decodable {
    let width: Int
    let height: Int
}

/// Video embed DTO
struct EmbedVideoDTO: Decodable {
    let thumbnail: String?
    let playlist: String
    let alt: String?
    let aspectRatio: AspectRatioDTO?
}

/// External link embed DTO
struct EmbedExternalDTO: Decodable {
    let external: ExternalLinkDTO
}

/// External link details
struct ExternalLinkDTO: Decodable {
    let uri: String
    let title: String
    let description: String
    let thumb: String?
}

/// Record embed DTO (quote post)
struct EmbedRecordDTO: Decodable {
    let record: RecordViewDTO
}

/// Record with media embed DTO
struct EmbedRecordWithMediaDTO: Decodable {
    let record: EmbedRecordDTO
    let media: EmbedMediaDTO
}

/// Media in recordWithMedia - either images or video
enum EmbedMediaDTO: Decodable {
    case images(EmbedImagesDTO)
    case video(EmbedVideoDTO)
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        
        switch type {
        case "app.bsky.embed.images#view":
            self = .images(try EmbedImagesDTO(from: decoder))
        case "app.bsky.embed.video#view":
            self = .video(try EmbedVideoDTO(from: decoder))
        default:
            self = .unknown
        }
    }
}

/// View of a quoted record (can be post, not found, blocked, etc.)
enum RecordViewDTO: Decodable {
    case post(RecordPostDTO)
    case notFound
    case blocked
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        
        switch type {
        case "app.bsky.embed.record#viewRecord":
            self = .post(try RecordPostDTO(from: decoder))
        case "app.bsky.embed.record#viewNotFound":
            self = .notFound
        case "app.bsky.embed.record#viewBlocked":
            self = .blocked
        default:
            self = .unknown
        }
    }
}

/// Quoted post record details
struct RecordPostDTO: Decodable {
    let uri: String
    let cid: String
    let author: AuthorDTO
    let value: RecordPostValueDTO
    let indexedAt: String
}

/// Value/content of a quoted post record
struct RecordPostValueDTO: Decodable {
    let text: String
    let createdAt: String
}

