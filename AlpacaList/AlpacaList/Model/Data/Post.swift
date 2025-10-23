//
//  Post.swift
//  AlpacaList
//
//  Core Bluesky post model (replaces Reddit-style FeedItem)
//

import Foundation

/// Represents a Bluesky post (micro-blog post, no title)
struct Post: Identifiable, Codable, Equatable {
    let id: UUID
    
    // AT Protocol identifiers
    let uri: String          // at:// URI (e.g., "at://did:plc:xyz/app.bsky.feed.post/abc123")
    let cid: String          // Content identifier (cryptographic hash)
    
    // Author info
    let author: Author
    let createdAt: Date
    
    // Content (no title - just text, max ~300 chars)
    let text: String
    let facets: [Facet]?     // Rich text (mentions, links, hashtags)
    let embed: Embed?        // Images, videos, quoted posts, external links
    let langs: [String]?     // Language codes (BCP-47, e.g., ["en", "es"])
    
    // Threading (simpler than Reddit - just parent/root references)
    let reply: ReplyRef?     // Parent and root post references
    
    // Engagement metrics
    var likeCount: Int
    var repostCount: Int
    var replyCount: Int
    var quoteCount: Int?
    
    // User interaction state (mutable)
    var isLiked: Bool
    var isReposted: Bool
    var isBookmarked: Bool
    
    // For reposts (when this post appears in timeline as a repost)
    let repostedBy: Author?
    
    // Record URIs for user interactions (needed for delete operations)
    var likeUri: String?      // URI of user's like record
    var repostUri: String?    // URI of user's repost record
    
    // MARK: - Initializer
    
    init(
        id: UUID = UUID(),
        uri: String,
        cid: String,
        author: Author,
        createdAt: Date,
        text: String,
        facets: [Facet]? = nil,
        embed: Embed? = nil,
        langs: [String]? = nil,
        reply: ReplyRef? = nil,
        likeCount: Int = 0,
        repostCount: Int = 0,
        replyCount: Int = 0,
        quoteCount: Int? = nil,
        isLiked: Bool = false,
        isReposted: Bool = false,
        isBookmarked: Bool = false,
        repostedBy: Author? = nil,
        likeUri: String? = nil,
        repostUri: String? = nil
    ) {
        self.id = id
        self.uri = uri
        self.cid = cid
        self.author = author
        self.createdAt = createdAt
        self.text = text
        self.facets = facets
        self.embed = embed
        self.langs = langs
        self.reply = reply
        self.likeCount = likeCount
        self.repostCount = repostCount
        self.replyCount = replyCount
        self.quoteCount = quoteCount
        self.isLiked = isLiked
        self.isReposted = isReposted
        self.isBookmarked = isBookmarked
        self.repostedBy = repostedBy
        self.likeUri = likeUri
        self.repostUri = repostUri
    }
    
    // MARK: - Convenience properties
    
    /// Is this a reply to another post?
    var isReply: Bool {
        reply != nil
    }
    
    /// Does this post have media?
    var hasMedia: Bool {
        embed?.hasImages == true || embed?.hasVideo == true
    }
    
    /// Is this a quote post?
    var isQuotePost: Bool {
        embed?.isQuotePost == true
    }
    
    /// Does this post have an external link?
    var hasExternalLink: Bool {
        if case .external = embed {
            return true
        }
        return false
    }
    
    /// Total engagement count
    var totalEngagement: Int {
        likeCount + repostCount + replyCount + (quoteCount ?? 0)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id && lhs.uri == rhs.uri && lhs.cid == rhs.cid
    }
}

// MARK: - Mock/Preview helpers

extension Post {
    /// Create a simple text post for testing/preview
    static func createTextPost(
        author: Author,
        text: String,
        createdAt: Date = Date()
    ) -> Post {
        Post(
            uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
            cid: "bafyrei\(UUID().uuidString.prefix(16))",
            author: author,
            createdAt: createdAt,
            text: text
        )
    }
    
    /// Create a post with images for testing/preview
    static func createImagePost(
        author: Author,
        text: String,
        images: [Embed.ImageEmbed],
        createdAt: Date = Date()
    ) -> Post {
        Post(
            uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
            cid: "bafyrei\(UUID().uuidString.prefix(16))",
            author: author,
            createdAt: createdAt,
            text: text,
            embed: .images(images)
        )
    }
    
    /// Create a reply post for testing/preview
    static func createReply(
        author: Author,
        text: String,
        replyTo: Post,
        createdAt: Date = Date()
    ) -> Post {
        let replyRef = ReplyRef(
            root: ReplyRef.StrongRef(uri: replyTo.uri, cid: replyTo.cid),
            parent: ReplyRef.StrongRef(uri: replyTo.uri, cid: replyTo.cid)
        )
        
        return Post(
            uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
            cid: "bafyrei\(UUID().uuidString.prefix(16))",
            author: author,
            createdAt: createdAt,
            text: text,
            reply: replyRef
        )
    }
}

