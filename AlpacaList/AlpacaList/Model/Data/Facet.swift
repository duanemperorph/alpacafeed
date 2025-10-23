//
//  Facet.swift
//  AlpacaList
//
//  Rich text features for Bluesky posts (mentions, links, hashtags)
//

import Foundation

/// Represents a rich text feature in a post (mention, link, hashtag)
struct Facet: Codable, Equatable {
    let index: ByteSlice
    let features: [Feature]
    
    /// Byte range in the post text
    struct ByteSlice: Codable, Equatable {
        let byteStart: Int
        let byteEnd: Int
    }
    
    /// Types of rich text features
    enum Feature: Codable, Equatable {
        case mention(did: String)
        case link(uri: String)
        case tag(tag: String)
        
        enum CodingKeys: String, CodingKey {
            case type = "$type"
            case did, uri, tag
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "app.bsky.richtext.facet#mention":
                let did = try container.decode(String.self, forKey: .did)
                self = .mention(did: did)
            case "app.bsky.richtext.facet#link":
                let uri = try container.decode(String.self, forKey: .uri)
                self = .link(uri: uri)
            case "app.bsky.richtext.facet#tag":
                let tag = try container.decode(String.self, forKey: .tag)
                self = .tag(tag: tag)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Unknown facet type: \(type)"
                )
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .mention(let did):
                try container.encode("app.bsky.richtext.facet#mention", forKey: .type)
                try container.encode(did, forKey: .did)
            case .link(let uri):
                try container.encode("app.bsky.richtext.facet#link", forKey: .type)
                try container.encode(uri, forKey: .uri)
            case .tag(let tag):
                try container.encode("app.bsky.richtext.facet#tag", forKey: .type)
                try container.encode(tag, forKey: .tag)
            }
        }
    }
}

