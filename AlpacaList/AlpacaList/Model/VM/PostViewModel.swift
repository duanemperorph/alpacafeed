//
//  PostViewModel.swift
//  AlpacaList
//
//  Unified post view model (replaces FeedItemViewModel)
//

import Foundation
import SwiftUI

/// View model for individual post display (no style/indentation distinction)
class PostViewModel: ObservableObject, Identifiable {
    // MARK: - Properties
    
    let post: Post
    
    var id: UUID {
        post.id
    }
    
    // MARK: - Initialization
    
    init(post: Post) {
        self.post = post
    }
    
    // MARK: - Display Helpers
    
    /// Formatted date string (e.g., "2h", "3d", "Jan 15")
    var formattedDate: String {
        let now = Date()
        let interval = now.timeIntervalSince(post.createdAt)
        
        // Less than 1 minute
        if interval < 60 {
            return "now"
        }
        
        // Less than 1 hour
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        }
        
        // Less than 24 hours
        if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        }
        
        // Less than 7 days
        if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d"
        }
        
        // More than 7 days - show actual date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: post.createdAt)
    }
    
    /// Full date string for detail view
    var fullFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: post.createdAt)
    }
    
    /// Display text with facets applied
    /// TODO: In actual implementation, this would return AttributedString with clickable links
    var displayText: String {
        post.text
    }
    
    /// Does this post have media?
    var hasMedia: Bool {
        post.hasMedia
    }
    
    /// Is this a quote post?
    var isQuotePost: Bool {
        post.isQuotePost
    }
    
    /// Does this post have an external link?
    var hasExternalLink: Bool {
        post.hasExternalLink
    }
    
    /// Is this a reply to another post?
    var isReply: Bool {
        post.isReply
    }
    
    /// Is this a repost (shown via repostedBy)?
    var isRepost: Bool {
        post.repostedBy != nil
    }
    
    // MARK: - Engagement Helpers
    
    /// Formatted like count (e.g., "1.2K", "5.3M")
    var formattedLikeCount: String {
        formatCount(post.likeCount)
    }
    
    /// Formatted repost count
    var formattedRepostCount: String {
        formatCount(post.repostCount)
    }
    
    /// Formatted reply count
    var formattedReplyCount: String {
        formatCount(post.replyCount)
    }
    
    /// Formatted quote count
    var formattedQuoteCount: String {
        formatCount(post.quoteCount ?? 0)
    }
    
    /// Total engagement count
    var totalEngagement: Int {
        post.totalEngagement
    }
    
    // MARK: - Author Helpers
    
    /// Author's display name or handle
    var authorDisplayName: String {
        post.author.displayNameOrHandle
    }
    
    /// Author's handle (without @)
    var authorHandle: String {
        post.author.handle
    }
    
    /// Author's handle (with @)
    var authorHandleWithAt: String {
        "@\(post.author.handle)"
    }
    
    /// Reposted by text (if applicable)
    var repostedByText: String? {
        if let repostedBy = post.repostedBy {
            return "\(repostedBy.displayNameOrHandle) reposted"
        }
        return nil
    }
    
    // MARK: - Private Helpers
    
    private func formatCount(_ count: Int) -> String {
        if count == 0 {
            return ""
        } else if count < 1000 {
            return "\(count)"
        } else if count < 1_000_000 {
            let k = Double(count) / 1000.0
            return String(format: "%.1fK", k)
        } else {
            let m = Double(count) / 1_000_000.0
            return String(format: "%.1fM", m)
        }
    }
}

// MARK: - Rich Text Parsing (Future Enhancement)

extension PostViewModel {
    /// Parse facets into attributed string segments
    /// TODO: Implement full rich text rendering
    struct TextSegment {
        let text: String
        let type: SegmentType
        
        enum SegmentType {
            case plain
            case mention(did: String)
            case link(url: String)
            case hashtag(tag: String)
        }
    }
    
    /// Parse post text into segments using facets
    func parseTextSegments() -> [TextSegment] {
        guard let facets = post.facets, !facets.isEmpty else {
            return [TextSegment(text: post.text, type: .plain)]
        }
        
        // TODO: Implement full facet parsing
        // This would:
        // 1. Sort facets by byte position
        // 2. Split text into segments
        // 3. Apply facet types to segments
        // 4. Return array of typed segments
        
        // For now, just return plain text
        return [TextSegment(text: post.text, type: .plain)]
    }
}

// MARK: - Embed Helpers

extension PostViewModel {
    /// Get image embeds
    var imageEmbeds: [Embed.ImageEmbed]? {
        switch post.embed {
        case .images(let images):
            return images
        case .recordWithMedia(_, .images(let images)):
            return images
        default:
            return nil
        }
    }
    
    /// Get video embed
    var videoEmbed: Embed.VideoEmbed? {
        switch post.embed {
        case .video(let video):
            return video
        case .recordWithMedia(_, .video(let video)):
            return video
        default:
            return nil
        }
    }
    
    /// Get external link embed
    var externalEmbed: Embed.ExternalEmbed? {
        if case .external(let external) = post.embed {
            return external
        }
        return nil
    }
    
    /// Get quote post embed
    var quoteEmbed: Embed.RecordEmbed? {
        switch post.embed {
        case .record(let record):
            return record
        case .recordWithMedia(let record, _):
            return record
        default:
            return nil
        }
    }
}

