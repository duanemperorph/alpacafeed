//
//  BlueskyFeedClient.swift
//  AlpacaList
//
//  API client for Bluesky feed endpoints (app.bsky.*)
//

import Foundation

/// API client for Bluesky feed endpoints (app.bsky.*)
/// Handles timeline, post thread, and post action calls
class BlueskyFeedClient {
    
    // MARK: - Dependencies
    
    private let client: ATProtoClient
    
    // MARK: - Initialization
    
    init(client: ATProtoClient = ATProtoClient()) {
        self.client = client
    }
    
    // MARK: - Timeline
    
    /// Get the user's home timeline
    /// - Parameters:
    ///   - accessToken: Valid access JWT
    ///   - server: PDS server hostname
    ///   - cursor: Pagination cursor
    ///   - limit: Max posts to return (default: 50)
    /// - Returns: Timeline response with posts and cursor
    /// - Throws: APIError on failure
    ///
    /// API: GET /xrpc/app.bsky.feed.getTimeline
    func getTimeline(accessToken: String, server: String, cursor: String? = nil, limit: Int = 50) async throws -> TimelineResponse {
        // TODO: Implementation
        fatalError("Not implemented")
    }
    
    // MARK: - Post Thread
    
    /// Get a post thread (post + replies)
    /// - Parameters:
    ///   - uri: The post URI
    ///   - accessToken: Valid access JWT
    ///   - server: PDS server hostname
    ///   - depth: How deep to fetch replies (default: 6)
    /// - Returns: Thread response with post and replies
    /// - Throws: APIError on failure
    ///
    /// API: GET /xrpc/app.bsky.feed.getPostThread
    func getPostThread(uri: String, accessToken: String, server: String, depth: Int = 6) async throws -> ThreadResponse {
        // TODO: Implementation
        fatalError("Not implemented")
    }
    
    // MARK: - Post Actions
    
    /// Create a new post
    /// - Parameters:
    ///   - text: Post text content
    ///   - replyTo: Optional parent post for replies
    ///   - accessToken: Valid access JWT
    ///   - server: PDS server hostname
    /// - Returns: The created post reference
    /// - Throws: APIError on failure
    ///
    /// API: POST /xrpc/com.atproto.repo.createRecord
    func createPost(text: String, replyTo: ReplyRef? = nil, accessToken: String, server: String) async throws -> CreateRecordResponse {
        // TODO: Implementation
        fatalError("Not implemented")
    }
    
    /// Like a post
    /// - Parameters:
    ///   - uri: The post URI to like
    ///   - cid: The post CID
    ///   - accessToken: Valid access JWT
    ///   - server: PDS server hostname
    /// - Returns: The like record reference
    /// - Throws: APIError on failure
    ///
    /// API: POST /xrpc/com.atproto.repo.createRecord (app.bsky.feed.like)
    func likePost(uri: String, cid: String, accessToken: String, server: String) async throws -> CreateRecordResponse {
        // TODO: Implementation
        fatalError("Not implemented")
    }
    
    /// Unlike a post (delete like record)
    /// - Parameters:
    ///   - likeUri: The like record URI to delete
    ///   - accessToken: Valid access JWT
    ///   - server: PDS server hostname
    /// - Throws: APIError on failure
    ///
    /// API: POST /xrpc/com.atproto.repo.deleteRecord
    func unlikePost(likeUri: String, accessToken: String, server: String) async throws {
        // TODO: Implementation
        fatalError("Not implemented")
    }
    
    /// Repost a post
    /// - Parameters:
    ///   - uri: The post URI to repost
    ///   - cid: The post CID
    ///   - accessToken: Valid access JWT
    ///   - server: PDS server hostname
    /// - Returns: The repost record reference
    /// - Throws: APIError on failure
    ///
    /// API: POST /xrpc/com.atproto.repo.createRecord (app.bsky.feed.repost)
    func repost(uri: String, cid: String, accessToken: String, server: String) async throws -> CreateRecordResponse {
        // TODO: Implementation
        fatalError("Not implemented")
    }
    
    /// Delete a repost
    /// - Parameters:
    ///   - repostUri: The repost record URI to delete
    ///   - accessToken: Valid access JWT
    ///   - server: PDS server hostname
    /// - Throws: APIError on failure
    ///
    /// API: POST /xrpc/com.atproto.repo.deleteRecord
    func deleteRepost(repostUri: String, accessToken: String, server: String) async throws {
        // TODO: Implementation
        fatalError("Not implemented")
    }
}

// MARK: - Response Types
// TODO: Move these to Model/Data/ when implementing

/// Response from getTimeline
/// API returns: { "feed": [...], "cursor": "..." }
struct TimelineResponse: Decodable {
    // TODO: Define feed item structure matching API response
    // let feed: [BlueskyFeedViewPost]
    let cursor: String?
}

/// Response from getPostThread
/// API returns: { "thread": { "post": ..., "parent": ..., "replies": [...] } }
struct ThreadResponse: Decodable {
    // TODO: Define thread structure matching API response
    // let thread: BlueskyThreadViewPost
}

/// Response from createRecord
/// API returns: { "uri": "at://...", "cid": "..." }
struct CreateRecordResponse: Decodable {
    let uri: String
    let cid: String
}

