//
//  PostCache.swift
//  AlpacaList
//
//  Thread-safe actor for caching posts globally
//

import Foundation

/// Actor for thread-safe post caching
/// Provides global cache for posts to avoid duplicates and enable optimistic updates
actor PostCache {
    private var posts: [String: Post] = [:]  // uri -> Post
    
    // MARK: - Read operations
    
    /// Get a post by URI
    func getPost(uri: String) -> Post? {
        return posts[uri]
    }
    
    /// Get multiple posts by URIs
    func getPosts(uris: [String]) -> [Post] {
        return uris.compactMap { posts[$0] }
    }
    
    /// Get all cached posts
    func getAllPosts() -> [Post] {
        return Array(posts.values)
    }
    
    // MARK: - Write operations
    
    /// Cache a single post
    func cachePost(_ post: Post) {
        posts[post.uri] = post
    }
    
    /// Cache multiple posts
    func cachePosts(_ posts: [Post]) {
        for post in posts {
            self.posts[post.uri] = post
        }
    }
    
    /// Update a post (for optimistic updates)
    func updatePost(_ post: Post) {
        posts[post.uri] = post
    }
    
    /// Update post interaction state
    func updateInteraction(uri: String, likeCount: Int? = nil, repostCount: Int? = nil, replyCount: Int? = nil, isLiked: Bool? = nil, isReposted: Bool? = nil, likeUri: String? = nil, repostUri: String? = nil) {
        guard var post = posts[uri] else { return }
        
        if let likeCount = likeCount {
            post.likeCount = likeCount
        }
        if let repostCount = repostCount {
            post.repostCount = repostCount
        }
        if let replyCount = replyCount {
            post.replyCount = replyCount
        }
        if let isLiked = isLiked {
            post.isLiked = isLiked
        }
        if let isReposted = isReposted {
            post.isReposted = isReposted
        }
        if let likeUri = likeUri {
            post.likeUri = likeUri
        }
        if let repostUri = repostUri {
            post.repostUri = repostUri
        }
        
        posts[uri] = post
    }
    
    /// Clear all cached posts
    func clear() {
        posts.removeAll()
    }
    
    /// Remove a specific post
    func removePost(uri: String) {
        posts.removeValue(forKey: uri)
    }
}

