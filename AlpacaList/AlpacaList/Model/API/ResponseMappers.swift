//
//  ResponseMappers.swift
//  AlpacaList
//
//  Maps API response types (DTOs) to app domain models
//

import Foundation

// MARK: - AuthorDTO → Author

extension AuthorDTO {
    /// Convert API AuthorDTO to app Author model
    func toAuthor() -> Author {
        Author(
            did: did,
            handle: handle,
            displayName: displayName,
            avatar: avatar
        )
    }
}

// MARK: - PostDTO → Post

extension PostDTO {
    /// Convert API PostDTO to app Post model
    /// - Parameter repostedBy: Optional author who reposted this (from FeedReasonDTO)
    func toPost(repostedBy: Author? = nil) -> Post {
        Post(
            uri: uri,
            cid: cid,
            author: author.toAuthor(),
            createdAt: parseDate(record.createdAt),
            text: record.text,
            facets: nil,  // TODO: Parse facets from record
            embed: nil,   // TODO: Parse embed from response
            langs: nil,
            reply: nil,   // TODO: Parse reply ref from record
            likeCount: likeCount ?? 0,
            repostCount: repostCount ?? 0,
            replyCount: replyCount ?? 0,
            quoteCount: nil,
            isLiked: viewer?.like != nil,
            isReposted: viewer?.repost != nil,
            isBookmarked: false,
            repostedBy: repostedBy,
            likeUri: viewer?.like,
            repostUri: viewer?.repost
        )
    }
    
    /// Parse ISO8601 date string to Date
    private func parseDate(_ dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString) ?? Date()
    }
}

// MARK: - FeedItemDTO → Post

extension FeedItemDTO {
    /// Convert API FeedItemDTO to app Post model
    /// Handles repost attribution via reason field
    func toPost() -> Post {
        // Check if this is a repost
        let repostedBy: Author?
        if reason?.type == "app.bsky.feed.defs#reasonRepost",
           let by = reason?.by {
            repostedBy = by.toAuthor()
        } else {
            repostedBy = nil
        }
        
        return post.toPost(repostedBy: repostedBy)
    }
}

// MARK: - TimelineResponse → [Post]

extension TimelineResponse {
    /// Convert timeline response to array of Posts
    func toPosts() -> [Post] {
        feed.map { $0.toPost() }
    }
}

// MARK: - ThreadItemDTO → Thread Components

extension ThreadItemDTO {
    /// Flatten thread into components: root post, parent chain, and replies
    /// - Returns: Tuple of (rootPost, parentPosts, replies)
    func flatten() -> (root: Post, parents: [Post], replies: [Post]) {
        let rootPost = post.toPost()
        let parents = collectParents()
        let replies = collectReplies()
        
        return (rootPost, parents, replies)
    }
    
    /// Collect parent posts in chronological order (oldest first)
    private func collectParents() -> [Post] {
        var parents: [Post] = []
        var current: ThreadParentDTO? = parent
        
        while let parentNode = current {
            switch parentNode {
            case .post(let threadItem):
                parents.insert(threadItem.post.toPost(), at: 0)  // Insert at start for chronological order
                current = threadItem.parent
            case .notFound, .blocked:
                current = nil
            }
        }
        
        return parents
    }
    
    /// Collect direct replies (flattened, not nested)
    private func collectReplies() -> [Post] {
        guard let replies = replies else { return [] }
        
        var result: [Post] = []
        
        for reply in replies {
            switch reply {
            case .post(let threadItem):
                result.append(threadItem.post.toPost())
                // Optionally flatten nested replies too
                result.append(contentsOf: threadItem.collectNestedReplies())
            case .notFound, .blocked:
                continue
            }
        }
        
        return result
    }
    
    /// Recursively collect nested replies
    private func collectNestedReplies() -> [Post] {
        guard let replies = replies else { return [] }
        
        var result: [Post] = []
        
        for reply in replies {
            switch reply {
            case .post(let threadItem):
                result.append(threadItem.post.toPost())
                result.append(contentsOf: threadItem.collectNestedReplies())
            case .notFound, .blocked:
                continue
            }
        }
        
        return result
    }
}

// MARK: - ThreadResponse convenience

extension ThreadResponse {
    /// Flatten the thread response into components
    func flatten() -> (root: Post, parents: [Post], replies: [Post]) {
        thread.flatten()
    }
}

