//
//  ReplyRef.swift
//  AlpacaList
//
//  Reply reference for threading posts
//

import Foundation

/// Reference to parent and root posts for threading
struct ReplyRef: Codable, Equatable {
    let root: StrongRef
    let parent: StrongRef
    
    /// Strong reference to a post (AT Protocol identifier)
    struct StrongRef: Codable, Equatable {
        let uri: String  // at:// URI
        let cid: String  // Content identifier
    }
}

