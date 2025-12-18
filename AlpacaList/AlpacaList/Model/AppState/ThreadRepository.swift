//
//  ThreadRepository.swift
//  AlpacaList
//
//  Repository for fetching and managing post threads
//

import Foundation
import Observation

/// Repository for thread operations
/// Each instance manages one specific thread (identified by root post URI)
///
/// Uses progressive depth fetching instead of cursor pagination
/// (Bluesky's getPostThread doesn't support cursors)
/// - Initial fetch: depth=100
/// - Load more doubles depth: 100 → 200 → 400 (max)
@Observable
@MainActor
class ThreadRepository {
    private let postCache: PostCache
    private let profileCache: ProfileCache
    private let feedService: FeedService
    private let postUri: String  // The root post URI this repository manages
    
    // Thread state - stores URIs and cached posts
    private var parentPostUris: [String] = []
    private var replyPostUris: [String] = []
    
    private(set) var rootPost: Post?
    private(set) var parentPosts: [Post] = []
    private(set) var replies: [Post] = []
    
    // Loading states
    private(set) var isLoading = false
    private(set) var isLoadingMoreReplies = false
    
    // Error state
    private(set) var error: Error?
    
    // Depth-based pagination (Bluesky doesn't support cursor for threads)
    private static let initialDepth = 100
    private static let maxDepth = 400
    private var currentDepth: Int = ThreadRepository.initialDepth
    
    init(postUri: String, postCache: PostCache, profileCache: ProfileCache, feedService: FeedService) {
        self.postUri = postUri
        self.postCache = postCache
        self.profileCache = profileCache
        self.feedService = feedService
    }
    
    /// Refresh posts from cache - call this to get latest post states
    func refreshPostsFromCache() async {
        rootPost = await postCache.getPost(uri: postUri)
        parentPosts = await postCache.getPosts(uris: parentPostUris)
        replies = await postCache.getPosts(uris: replyPostUris)
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch a post thread (main post + parents + replies)
    /// - Parameter replaceExisting: If true, replaces all reply URIs. If false, appends only new URIs (preserves scroll position)
    func fetchThread(replaceExisting: Bool = true) async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            // Fetch thread from API
            let response = try await feedService.getPostThread(uri: postUri, depth: currentDepth)
            
            // Flatten thread into components
            let (mainPost, fetchedParents, fetchedReplies) = response.flatten()
            
            // Cache all posts (updates existing posts with fresh data)
            await postCache.cachePost(mainPost)
            await postCache.cachePosts(fetchedParents)
            await postCache.cachePosts(fetchedReplies)
            
            // Cache authors
            let allAuthors = [mainPost.author] + fetchedParents.map { $0.author } + fetchedReplies.map { $0.author }
            await profileCache.cacheProfiles(allAuthors)
            
            // Update internal state
            self.parentPostUris = fetchedParents.map { $0.uri }
            
            if replaceExisting {
                // Full replace (used for initial fetch and refresh)
                self.replyPostUris = fetchedReplies.map { $0.uri }
            } else {
                // Append-only merge (preserves scroll position for load more)
                let existingUriSet = Set(replyPostUris)
                let newUris = fetchedReplies.map { $0.uri }.filter { !existingUriSet.contains($0) }
                self.replyPostUris.append(contentsOf: newUris)
            }
            
            await self.refreshPostsFromCache()
        } catch {
            self.error = error
        }
    }
    
    /// Load more replies by doubling the fetch depth
    /// Uses append-only merge to preserve scroll position
    func loadMoreReplies() async {
        guard canLoadMoreReplies, !isLoadingMoreReplies, !isLoading else {
            return
        }
        
        isLoadingMoreReplies = true
        defer { isLoadingMoreReplies = false }
        
        // Double the depth (capped at max)
        currentDepth = min(currentDepth * 2, Self.maxDepth)
        
        // Re-fetch with higher depth, appending only new replies
        await fetchThread(replaceExisting: false)
    }
    
    /// Refresh thread (pull to refresh)
    /// Resets depth to initial value and replaces all data
    func refresh() async {
        // Reset depth and fetch fresh
        currentDepth = Self.initialDepth
        
        await fetchThread(replaceExisting: true)
    }
    
    /// Reset state
    func reset() {
        parentPostUris = []
        replyPostUris = []
        rootPost = nil
        parentPosts = []
        replies = []
        currentDepth = Self.initialDepth
    }
    
    /// Check if there are more replies to load (depth can still be increased)
    var canLoadMoreReplies: Bool {
        return currentDepth < Self.maxDepth
    }
    
    // MARK: - Supporting Types
    
    enum ThreadError: Error {
        case postNotFound
        case invalidUri
    }
}

