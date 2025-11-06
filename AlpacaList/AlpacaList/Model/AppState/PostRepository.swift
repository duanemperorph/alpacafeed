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
    
    // Error state for post operations
    private(set) var error: Error?
    
    init(postCache: PostCache) {
        self.postCache = postCache
    }
    
    // MARK: - Post Creation
    
    /// Create a new post
    func createPost(text: String, replyTo: Post? = nil, embed: Embed? = nil) async -> Post? {
        error = nil
        
        do {
            // TODO: Replace with actual API call to com.atproto.repo.createRecord
            // For now, create a mock post
            
            let author = mockAuthors[0]  // Use mock current user
            
            let reply: ReplyRef? = replyTo.map { parent in
                ReplyRef(
                    root: ReplyRef.StrongRef(uri: parent.uri, cid: parent.cid),
                    parent: ReplyRef.StrongRef(uri: parent.uri, cid: parent.cid)
                )
            }
            
            let post = Post(
                uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
                cid: "bafyrei\(UUID().uuidString.prefix(16))",
                author: author,
                createdAt: Date(),
                text: text,
                embed: embed,
                reply: reply
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
    
    // MARK: - Like Operations
    
    /// Like a post
    func likePost(uri: String) async {
        error = nil
        
        do {
            // TODO: Replace with actual API call to com.atproto.repo.createRecord
            // For now, update cache optimistically
            
            guard let post = await postCache.getPost(uri: uri) else {
                throw PostError.postNotFound
            }
            
            guard !post.isLiked else {
                // Already liked
                return
            }
            
            let likeUri = "at://\(post.author.did)/app.bsky.feed.like/\(UUID().uuidString)"
            
            await postCache.updateInteraction(
                uri: uri,
                likeCount: post.likeCount + 1,
                isLiked: true,
                likeUri: likeUri
            )
        } catch {
            self.error = error
        }
    }
    
    /// Unlike a post
    func unlikePost(uri: String) async {
        error = nil
        
        do {
            // TODO: Replace with actual API call to com.atproto.repo.deleteRecord
            // For now, update cache optimistically
            
            guard let post = await postCache.getPost(uri: uri) else {
                throw PostError.postNotFound
            }
            
            guard post.isLiked else {
                // Not liked
                return
            }
            
            await postCache.updateInteraction(
                uri: uri,
                likeCount: max(0, post.likeCount - 1),
                isLiked: false,
                likeUri: nil
            )
        } catch {
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
        
        do {
            // TODO: Replace with actual API call to com.atproto.repo.deleteRecord
            // For now, just remove from cache
            
            await postCache.removePost(uri: uri)
        } catch {
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

