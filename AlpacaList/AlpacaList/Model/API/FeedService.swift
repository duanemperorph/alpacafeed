//
//  FeedService.swift
//  AlpacaList
//
//  Service for Bluesky feed operations (app.bsky.*)
//

import Foundation

/// Service for Bluesky feed operations (app.bsky.*)
/// Handles timeline, post thread, and post action calls
/// Uses BSAPIClient for automatic token management
class FeedService {
    
    // MARK: - Dependencies
    
    private let apiService: BSAPIClient
    
    // MARK: - Initialization
    
    init(apiService: BSAPIClient) {
        self.apiService = apiService
    }
    
    // MARK: - Timeline
    
    /// Get the user's home timeline
    /// - Parameters:
    ///   - cursor: Pagination cursor (nil for first page)
    ///   - limit: Max posts to return (default: 50, max: 100)
    /// - Returns: Timeline response with feed items and cursor
    /// - Throws: APIError on failure
    ///
    /// API: GET /xrpc/app.bsky.feed.getTimeline
    @MainActor
    func getTimeline(cursor: String? = nil, limit: Int = 50) async throws -> TimelineResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        
        return try await apiService.get(
            endpoint: "app.bsky.feed.getTimeline",
            queryItems: queryItems,
            responseType: TimelineResponse.self
        )
    }
    
    /// Get a custom feed (e.g., "What's Hot", user-created feeds)
    /// - Parameters:
    ///   - feedUri: The feed generator URI (at://...)
    ///   - cursor: Pagination cursor
    ///   - limit: Max posts to return
    /// - Returns: Feed response with items and cursor
    ///
    /// API: GET /xrpc/app.bsky.feed.getFeed
    @MainActor
    func getFeed(feedUri: String, cursor: String? = nil, limit: Int = 50) async throws -> TimelineResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "feed", value: feedUri),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        
        return try await apiService.get(
            endpoint: "app.bsky.feed.getFeed",
            queryItems: queryItems,
            responseType: TimelineResponse.self
        )
    }
    
    // MARK: - Post Thread
    
    /// Get a post thread (post + parent chain + replies)
    /// - Parameters:
    ///   - uri: The post URI (at://did/app.bsky.feed.post/rkey)
    ///   - depth: How deep to fetch replies (default: 6, max: 1000)
    ///   - parentHeight: How many parents to fetch (default: 80)
    /// - Returns: Thread response with post, parents, and replies
    ///
    /// API: GET /xrpc/app.bsky.feed.getPostThread
    @MainActor
    func getPostThread(uri: String, depth: Int = 6, parentHeight: Int = 80) async throws -> ThreadResponse {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "uri", value: uri),
            URLQueryItem(name: "depth", value: String(depth)),
            URLQueryItem(name: "parentHeight", value: String(parentHeight))
        ]
        
        return try await apiService.get(
            endpoint: "app.bsky.feed.getPostThread",
            queryItems: queryItems,
            responseType: ThreadResponse.self
        )
    }
    
    // MARK: - Post Actions
    
    /// Create a new post
    /// - Parameters:
    ///   - text: Post text content (max 300 chars / 3000 bytes)
    ///   - reply: Optional reply reference (parent + root)
    ///   - embed: Optional embed (images, link, quote)
    ///   - facets: Optional rich text facets (mentions, links, tags)
    /// - Returns: The created record reference (uri + cid)
    ///
    /// API: POST /xrpc/com.atproto.repo.createRecord
    @MainActor
    func createPost(
        text: String,
        reply: ReplyReference? = nil,
        embed: CreatePostEmbed? = nil,
        facets: [CreatePostFacet]? = nil
    ) async throws -> CreateRecordResponse {
        let record = PostRecord(
            text: text,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            reply: reply,
            embed: embed,
            facets: facets
        )
        
        let body = CreateRecordRequest(
            repo: try getDID(),
            collection: "app.bsky.feed.post",
            record: record
        )
        
        return try await apiService.post(
            endpoint: "com.atproto.repo.createRecord",
            body: body,
            responseType: CreateRecordResponse.self
        )
    }
    
    /// Like a post
    /// - Parameters:
    ///   - uri: The post URI to like
    ///   - cid: The post CID
    /// - Returns: The like record reference
    ///
    /// API: POST /xrpc/com.atproto.repo.createRecord (collection: app.bsky.feed.like)
    @MainActor
    func likePost(uri: String, cid: String) async throws -> CreateRecordResponse {
        let record = LikeRecord(
            subject: RecordRef(uri: uri, cid: cid),
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        let body = CreateRecordRequest(
            repo: try getDID(),
            collection: "app.bsky.feed.like",
            record: record
        )
        
        return try await apiService.post(
            endpoint: "com.atproto.repo.createRecord",
            body: body,
            responseType: CreateRecordResponse.self
        )
    }
    
    /// Unlike a post (delete like record)
    /// - Parameter likeUri: The like record URI to delete (at://did/app.bsky.feed.like/rkey)
    ///
    /// API: POST /xrpc/com.atproto.repo.deleteRecord
    @MainActor
    func unlikePost(likeUri: String) async throws {
        let (repo, rkey) = try parseRecordUri(likeUri)
        
        let body = DeleteRecordRequest(
            repo: repo,
            collection: "app.bsky.feed.like",
            rkey: rkey
        )
        
        try await apiService.post(endpoint: "com.atproto.repo.deleteRecord", body: body)
    }
    
    /// Repost a post
    /// - Parameters:
    ///   - uri: The post URI to repost
    ///   - cid: The post CID
    /// - Returns: The repost record reference
    ///
    /// API: POST /xrpc/com.atproto.repo.createRecord (collection: app.bsky.feed.repost)
    @MainActor
    func repost(uri: String, cid: String) async throws -> CreateRecordResponse {
        let record = RepostRecord(
            subject: RecordRef(uri: uri, cid: cid),
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        let body = CreateRecordRequest(
            repo: try getDID(),
            collection: "app.bsky.feed.repost",
            record: record
        )
        
        return try await apiService.post(
            endpoint: "com.atproto.repo.createRecord",
            body: body,
            responseType: CreateRecordResponse.self
        )
    }
    
    /// Delete a repost
    /// - Parameter repostUri: The repost record URI to delete
    ///
    /// API: POST /xrpc/com.atproto.repo.deleteRecord
    @MainActor
    func deleteRepost(repostUri: String) async throws {
        let (repo, rkey) = try parseRecordUri(repostUri)
        
        let body = DeleteRecordRequest(
            repo: repo,
            collection: "app.bsky.feed.repost",
            rkey: rkey
        )
        
        try await apiService.post(endpoint: "com.atproto.repo.deleteRecord", body: body)
    }
    
    /// Delete a post
    /// - Parameter postUri: The post record URI to delete
    ///
    /// API: POST /xrpc/com.atproto.repo.deleteRecord
    @MainActor
    func deletePost(postUri: String) async throws {
        let (repo, rkey) = try parseRecordUri(postUri)
        
        let body = DeleteRecordRequest(
            repo: repo,
            collection: "app.bsky.feed.post",
            rkey: rkey
        )
        
        try await apiService.post(endpoint: "com.atproto.repo.deleteRecord", body: body)
    }
    
    // MARK: - Helpers
    
    /// Get the current user's DID from the session
    @MainActor
    private func getDID() throws -> String {
        guard let did = apiService.currentDID else {
            throw APIError.invalidRequest(message: "Not authenticated")
        }
        return did
    }
    
    /// Parse a record URI into repo (DID) and rkey
    /// Format: at://did:plc:xxx/collection/rkey
    private func parseRecordUri(_ uri: String) throws -> (repo: String, rkey: String) {
        // at://did:plc:xxx/app.bsky.feed.post/3abc123
        let components = uri.replacingOccurrences(of: "at://", with: "").split(separator: "/")
        guard components.count >= 3 else {
            throw APIError.invalidRequest(message: "Invalid record URI format")
        }
        let repo = String(components[0])
        let rkey = String(components[2])
        return (repo, rkey)
    }
}

// MARK: - Request Types

/// Request to create a record
private struct CreateRecordRequest<T: Encodable>: Encodable {
    let repo: String
    let collection: String
    let record: T
}

/// Request to delete a record
private struct DeleteRecordRequest: Encodable {
    let repo: String
    let collection: String
    let rkey: String
}

// MARK: - Record Types

/// Post record structure
private struct PostRecord: Encodable {
    let type = "app.bsky.feed.post"
    let text: String
    let createdAt: String
    let reply: ReplyReference?
    let embed: CreatePostEmbed?
    let facets: [CreatePostFacet]?
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case text, createdAt, reply, embed, facets
    }
}

/// Like record structure
private struct LikeRecord: Encodable {
    let type = "app.bsky.feed.like"
    let subject: RecordRef
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case subject, createdAt
    }
}

/// Repost record structure
private struct RepostRecord: Encodable {
    let type = "app.bsky.feed.repost"
    let subject: RecordRef
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case subject, createdAt
    }
}

/// Reference to another record (uri + cid)
struct RecordRef: Encodable {
    let uri: String
    let cid: String
}

/// Reply reference for posts
struct ReplyReference: Encodable {
    let root: RecordRef
    let parent: RecordRef
}

/// Placeholder for post embeds (images, links, quotes)
/// TODO: Implement proper embed types
struct CreatePostEmbed: Encodable {
    // Will be expanded when implementing embeds
}

/// Placeholder for rich text facets (mentions, links, hashtags)
/// TODO: Implement proper facet types
struct CreatePostFacet: Encodable {
    // Will be expanded when implementing rich text
}
