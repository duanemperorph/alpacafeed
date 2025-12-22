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
    
    // Viewer state (relationship from current user's perspective)
    var followingUri: String?  // URI of follow record if current user follows this author
    var isFollowedBy: Bool     // True if this author follows the current user
    
    init(
        id: UUID = UUID(),
        did: String,
        handle: String,
        displayName: String? = nil,
        avatar: String? = nil,
        description: String? = nil,
        followersCount: Int? = nil,
        followsCount: Int? = nil,
        postsCount: Int? = nil,
        followingUri: String? = nil,
        isFollowedBy: Bool = false
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
        self.followingUri = followingUri
        self.isFollowedBy = isFollowedBy
    }
    
    /// Whether the current user is following this author
    var isFollowing: Bool {
        followingUri != nil
    }
    
    /// Display name or handle as fallback
    var displayNameOrHandle: String {
        displayName ?? handle
    }
}

