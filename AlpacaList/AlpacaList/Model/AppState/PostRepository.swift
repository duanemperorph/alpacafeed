//
//  PostRepository.swift
//  AlpacaList
//
//  Repository for post creation and interaction (like, repost, etc.)
//

import Foundation
import Observation

/// Repository for post interaction operations
@Observable
@MainActor
class PostRepository {
    private let postCache: PostCache
    private let feedService: FeedService
    
    // Error state for post operations
    private(set) var error: Error?
    
    init(postCache: PostCache, feedService: FeedService) {
        self.postCache = postCache
        self.feedService = feedService
    }
    
    // MARK: - Post Creation
    
    /// Create a new top-level post (not a reply)
    /// - Parameter text: The post text content
    /// - Returns: The created Post on success, nil on failure
    func createPost(text: String) async -> Post? {
        return await createPostInternal(text: text, replyTo: nil)
    }
    
    /// Create a reply to an existing post
    /// - Parameters:
    ///   - text: The reply text content
    ///   - replyTo: The post being replied to
    /// - Returns: The created Post on success, nil on failure
    func createReply(text: String, replyTo: Post) async -> Post? {
        return await createPostInternal(text: text, replyTo: replyTo)
    }
    
    /// Internal helper for post creation (both new posts and replies)
    private func createPostInternal(text: String, replyTo: Post?) async -> Post? {
        error = nil
        
        do {
            // Build reply reference if this is a reply
            let replyReference: ReplyReference? = replyTo.map { parent in
                // For replies, we need both root and parent references
                // If replying to a reply, root is the original post; otherwise root == parent
                let rootRef: RecordRef
                if let existingReply = parent.reply {
                    // Parent is itself a reply - use its root
                    rootRef = RecordRef(uri: existingReply.root.uri, cid: existingReply.root.cid)
                } else {
                    // Parent is a top-level post - it becomes the root
                    rootRef = RecordRef(uri: parent.uri, cid: parent.cid)
                }
                let parentRef = RecordRef(uri: parent.uri, cid: parent.cid)
                return ReplyReference(root: rootRef, parent: parentRef)
            }
            
            // Call the API
            let response = try await feedService.createPost(
                text: text,
                reply: replyReference
            )
            
            // Build the Post object from the response
            let author = try getCurrentUserAuthor()
            
            let replyRef: ReplyRef? = replyTo.map { parent in
                let rootRef: ReplyRef.StrongRef
                if let existingReply = parent.reply {
                    rootRef = existingReply.root
                } else {
                    rootRef = ReplyRef.StrongRef(uri: parent.uri, cid: parent.cid)
                }
                return ReplyRef(
                    root: rootRef,
                    parent: ReplyRef.StrongRef(uri: parent.uri, cid: parent.cid)
                )
            }
            
            let post = Post(
                uri: response.uri,
                cid: response.cid,
                author: author,
                createdAt: Date(),
                text: text,
                reply: replyRef
            )
            
            // Cache the new post
            await postCache.cachePost(post)
            
            // If replying, update the parent's reply count
            if let parent = replyTo {
                await postCache.updateInteraction(
                    uri: parent.uri,
                    replyCount: parent.replyCount + 1
                )
            }
            
            return post
        } catch {
            self.error = error
            return nil
        }
    }
    
    /// Get the current user as an Author
    private func getCurrentUserAuthor() throws -> Author {
        guard let did = feedService.currentUserDID,
              let handle = feedService.currentUserHandle else {
            throw PostError.unauthorized
        }
        
        // Create minimal Author from session info
        // Note: displayName and avatar will be nil until we fetch the full profile
        return Author(did: did, handle: handle, displayName: nil, avatar: nil)
    }
    
    // MARK: - Like Operations
    
    /// Like a post
    func likePost(uri: String) async {
        error = nil
        
        guard let post = await postCache.getPost(uri: uri) else {
            self.error = PostError.postNotFound
            return
        }
        
        guard !post.isLiked else {
            // Already liked
            return
        }
        
        // Optimistic update
        let originalLikeCount = post.likeCount
        await postCache.updateInteraction(
            uri: uri,
            likeCount: post.likeCount + 1,
            isLiked: true,
            likeUri: nil  // Will be set after API call
        )
        
        do {
            // Call the real API
            let response = try await feedService.likePost(uri: post.uri, cid: post.cid)
            
            // Update cache with the real like URI from the response
            await postCache.updateInteraction(
                uri: uri,
                likeUri: response.uri
            )
        } catch {
            // Rollback optimistic update on failure
            await postCache.updateInteraction(
                uri: uri,
                likeCount: originalLikeCount,
                isLiked: false,
                likeUri: nil
            )
            self.error = error
        }
    }
    
    /// Unlike a post
    func unlikePost(uri: String) async {
        error = nil
        
        guard let post = await postCache.getPost(uri: uri) else {
            self.error = PostError.postNotFound
            return
        }
        
        guard post.isLiked, let likeUri = post.likeUri else {
            // Not liked or missing like URI
            return
        }
        
        // Optimistic update
        let originalLikeCount = post.likeCount
        let originalLikeUri = likeUri
        await postCache.updateInteraction(
            uri: uri,
            likeCount: max(0, post.likeCount - 1),
            isLiked: false,
            likeUri: nil
        )
        
        do {
            // Call the real API to delete the like record
            try await feedService.unlikePost(likeUri: likeUri)
        } catch {
            // Rollback optimistic update on failure
            await postCache.updateInteraction(
                uri: uri,
                likeCount: originalLikeCount,
                isLiked: true,
                likeUri: originalLikeUri
            )
            self.error = error
        }
    }
    
    // MARK: - Repost Operations
    
    /// Repost a post
    func repost(uri: String) async {
        error = nil
        
        do {
            // TODO: Replace with actual API call to com.atproto.repo.createRecord
            // For now, update cache optimistically
            
            guard let post = await postCache.getPost(uri: uri) else {
                throw PostError.postNotFound
            }
            
            guard !post.isReposted else {
                // Already reposted
                return
            }
            
            let repostUri = "at://\(post.author.did)/app.bsky.feed.repost/\(UUID().uuidString)"
            
            await postCache.updateInteraction(
                uri: uri,
                repostCount: post.repostCount + 1,
                isReposted: true,
                repostUri: repostUri
            )
        } catch {
            self.error = error
        }
    }
    
    /// Delete a repost
    func deleteRepost(uri: String) async {
        error = nil
        
        do {
            // TODO: Replace with actual API call to com.atproto.repo.deleteRecord
            // For now, update cache optimistically
            
            guard let post = await postCache.getPost(uri: uri) else {
                throw PostError.postNotFound
            }
            
            guard post.isReposted else {
                // Not reposted
                return
            }
            
            await postCache.updateInteraction(
                uri: uri,
                repostCount: max(0, post.repostCount - 1),
                isReposted: false,
                repostUri: nil
            )
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Delete Operations
    
    /// Delete a post
    /// - Parameter uri: The post URI to delete
    func deletePost(uri: String) async {
        error = nil
        
        // Get post from cache for potential rollback
        let cachedPost = await postCache.getPost(uri: uri)
        
        // Optimistic update - remove from cache immediately
        await postCache.removePost(uri: uri)
        
        do {
            // Call the API to delete the post record
            try await feedService.deletePost(postUri: uri)
        } catch {
            // Rollback - restore the cached post if deletion failed
            if let post = cachedPost {
                await postCache.cachePost(post)
            }
            self.error = error
        }
    }
    
    // MARK: - Follow Operations
    
    /// Follow a user
    /// - Parameter author: The author to follow
    /// - Returns: The follow URI on success, nil on failure
    func followUser(_ author: Author) async -> String? {
        error = nil
        
        guard !author.isFollowing else {
            // Already following
            return author.followingUri
        }
        
        // Optimistic update - set a temporary follow URI
        let tempFollowUri = "at://temp/app.bsky.graph.follow/pending"
        await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: tempFollowUri)
        
        do {
            let response = try await feedService.followUser(did: author.did)
            
            // Update cache with the real follow URI
            await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: response.uri)
            
            return response.uri
        } catch {
            // Rollback optimistic update on failure
            await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: nil)
            self.error = error
            return nil
        }
    }
    
    /// Unfollow a user
    /// - Parameter author: The author to unfollow
    func unfollowUser(_ author: Author) async {
        error = nil
        
        guard let followUri = author.followingUri else {
            // Not following
            return
        }
        
        // Optimistic update
        await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: nil)
        
        do {
            try await feedService.unfollowUser(followUri: followUri)
        } catch {
            // Rollback optimistic update on failure
            await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: followUri)
            self.error = error
        }
    }
    
    /// Toggle follow state for an author
    /// - Parameter author: The author to follow/unfollow
    func toggleFollow(_ author: Author) async {
        if author.isFollowing {
            await unfollowUser(author)
        } else {
            _ = await followUser(author)
        }
    }
    
    // MARK: - Supporting Types
    
    enum PostError: Error {
        case postNotFound
        case unauthorized
        case invalidInput
    }
}

