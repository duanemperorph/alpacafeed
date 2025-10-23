//
//  Timeline.swift
//  AlpacaList
//
//  Timeline/Feed container with pagination support
//

import Foundation

/// Timeline feed container with cursor-based pagination
struct Timeline: Codable {
    let posts: [Post]
    let cursor: String?  // For pagination
    
    /// Empty timeline
    static let empty = Timeline(posts: [], cursor: nil)
}

/// Thread container for post thread view
struct Thread: Codable {
    let post: Post           // The main post
    let parent: Post?        // Parent post (if reply)
    let replies: [Post]      // Direct replies
    
    /// Just the main post
    static func single(_ post: Post) -> Thread {
        Thread(post: post, parent: nil, replies: [])
    }
}

