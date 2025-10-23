//
//  Author.swift
//  AlpacaList
//
//  Bluesky Author/Profile model
//

import Foundation

/// Represents a Bluesky user/author
struct Author: Identifiable, Codable, Equatable {
    let id: UUID
    
    // AT Protocol identifiers
    let did: String          // Decentralized identifier (e.g., "did:plc:...")
    let handle: String       // User handle (e.g., "alice.bsky.social")
    
    // Profile info
    let displayName: String?
    let avatar: String?      // URL to avatar image
    let description: String? // Bio/description
    
    // Optional metadata
    let followersCount: Int?
    let followsCount: Int?
    let postsCount: Int?
    
    init(
        id: UUID = UUID(),
        did: String,
        handle: String,
        displayName: String? = nil,
        avatar: String? = nil,
        description: String? = nil,
        followersCount: Int? = nil,
        followsCount: Int? = nil,
        postsCount: Int? = nil
    ) {
        self.id = id
        self.did = did
        self.handle = handle
        self.displayName = displayName
        self.avatar = avatar
        self.description = description
        self.followersCount = followersCount
        self.followsCount = followsCount
        self.postsCount = postsCount
    }
    
    /// Display name or handle as fallback
    var displayNameOrHandle: String {
        displayName ?? handle
    }
}

