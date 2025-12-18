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
    private let profileCache: ProfileCache
    private let feedService: FeedService
    
    // Error state for post operations
    private(set) var error: Error?
    
    init(postCache: PostCache, profileCache: ProfileCache, feedService: FeedService) {
        self.postCache = postCache
        self.profileCache = profileCache
        self.feedService = feedService
    }
    
    // MARK: - Post Creation
    
    /// Create a new top-level post
    func createPost(text: String, embed: Embed? = nil) async -> Post? {
        return await publishPost(text: text, embed: embed)
    }
    
    /// Create a reply to an existing post
    func createReply(text: String, to parent: Post, embed: Embed? = nil) async -> Post? {
        // Build reply references for the API
        // Root is the thread starter; parent is what we're directly replying to
        let rootRef = parent.reply?.root ?? ReplyRef.StrongRef(uri: parent.uri, cid: parent.cid)
        
        let apiReply = ReplyReference(
            root: RecordRef(uri: rootRef.uri, cid: rootRef.cid),
            parent: RecordRef(uri: parent.uri, cid: parent.cid)
        )
        
        let modelReply = ReplyRef(
            root: rootRef,
            parent: ReplyRef.StrongRef(uri: parent.uri, cid: parent.cid)
        )
        
        let post = await publishPost(text: text, apiReply: apiReply, modelReply: modelReply, embed: embed)
        
        // Update parent's reply count on success
        if post != nil {
            await postCache.updateInteraction(
                uri: parent.uri,
                replyCount: parent.replyCount + 1
            )
        }
        
        return post
    }
    
    /// Shared logic for publishing a post or reply
    private func publishPost(
        text: String,
        apiReply: ReplyReference? = nil,
        modelReply: ReplyRef? = nil,
        embed: Embed? = nil
    ) async -> Post? {
        error = nil
        
        do {
            let response = try await feedService.createPost(
                text: text,
                reply: apiReply,
                embed: nil,  // TODO: Convert Embed to CreatePostEmbed
                facets: nil  // TODO: Extract facets from text
            )
            
            let author = await getCurrentUserAuthor()
            
            let post = Post(
                uri: response.uri,
                cid: response.cid,
                author: author,
                createdAt: Date(),
                text: text,
                embed: embed,
                reply: modelReply
            )
            
            await postCache.cachePost(post)
            return post
        } catch {
            self.error = error
            return nil
        }
    }
    
    /// Get the current user's Author object
    private func getCurrentUserAuthor() async -> Author {
        // Try to get from profile cache by DID
        if let did = feedService.currentDID,
           let cached = await profileCache.getProfileByDID(did: did) {
            return cached
        }
        
        // Fallback: construct minimal Author from session info
        let did = feedService.currentDID ?? "unknown"
        let handle = feedService.currentHandle ?? "unknown"
        
        return Author(
            did: did,
            handle: handle,
            displayName: nil,
            avatar: nil
        )
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
    func deletePost(uri: String) async {
        error = nil
        
        // Optimistically remove from cache first for responsive UI
        let cachedPost = await postCache.getPost(uri: uri)
        await postCache.removePost(uri: uri)
        
        do {
            // Call the real API to delete the post record
            try await feedService.deletePost(postUri: uri)
        } catch {
            // Rollback: restore the post to cache if API call failed
            if let post = cachedPost {
                await postCache.cachePost(post)
            }
            self.error = error
        }
    }
    
    // MARK: - Supporting Types
    
    enum PostError: Error {
        case postNotFound
        case unauthorized
        case invalidInput
    }
}

