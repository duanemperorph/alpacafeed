//
//  PostCache.swift
//  AlpacaList
//
//  Thread-safe actor for caching posts globally
//

import Foundation

/// Actor for thread-safe post caching
/// Provides global cache for posts to avoid duplicates and enable optimistic updates
/// Uses ProfileCache as the single source of truth for author data
actor PostCache {
    private var posts: [String: Post] = [:]  // uri -> Post
    private let profileCache: ProfileCache
    
    // MARK: - Initialization
    
    init(profileCache: ProfileCache) {
        self.profileCache = profileCache
    }
    
    // MARK: - Read operations
    
    /// Get a post by URI (hydrated with latest author data from ProfileCache)
    func getPost(uri: String) async -> Post? {
        guard var post = posts[uri] else { return nil }
        // Hydrate with latest author data
        if let author = await profileCache.getProfileByDID(did: post.author.did) {
            post.author = author
        }
        return post
    }
    
    /// Get multiple posts by URIs (hydrated with latest author data)
    func getPosts(uris: [String]) async -> [Post] {
        var result: [Post] = []
        for uri in uris {
            if let post = await getPost(uri: uri) {
                result.append(post)
            }
        }
        return result
    }
    
    /// Get all cached posts (hydrated with latest author data)
    func getAllPosts() async -> [Post] {
        var result: [Post] = []
        for (_, var post) in posts {
            if let author = await profileCache.getProfileByDID(did: post.author.did) {
                post.author = author
            }
            result.append(post)
        }
        return result
    }
    
    // MARK: - Write operations
    
    /// Cache a single post (also caches author in ProfileCache)
    func cachePost(_ post: Post) async {
        posts[post.uri] = post
        await profileCache.cacheProfile(post.author)
    }
    
    /// Cache multiple posts (also caches authors in ProfileCache)
    func cachePosts(_ posts: [Post]) async {
        for post in posts {
            self.posts[post.uri] = post
            await profileCache.cacheProfile(post.author)
        }
    }
    
    /// Update a post (for optimistic updates)
    func updatePost(_ post: Post) async {
        posts[post.uri] = post
        await profileCache.cacheProfile(post.author)
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
    
    // MARK: - Author Follow State
    
    /// Update author's follow state (delegates to ProfileCache - single source of truth)
    func updateAuthorFollowState(authorDID: String, followingUri: String?) async {
        await profileCache.updateFollowState(did: authorDID, followingUri: followingUri)
    }
}
