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
@Observable
@MainActor
class ThreadRepository {
    private let postCache: PostCache
    private let profileCache: ProfileCache
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
    
    // Pagination state
    private var repliesCursor: String?
    private var hasMoreReplies = true
    
    init(postUri: String, postCache: PostCache, profileCache: ProfileCache) {
        self.postUri = postUri
        self.postCache = postCache
        self.profileCache = profileCache
    }
    
    /// Refresh posts from cache - call this to get latest post states
    func refreshPostsFromCache() async {
        rootPost = await postCache.getPost(uri: postUri)
        parentPosts = await postCache.getPosts(uris: parentPostUris)
        replies = await postCache.getPosts(uris: replyPostUris)
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch a post thread (main post + parents + replies)
    func fetchThread(depth: Int = 6) async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // TODO: Replace with actual API call to app.bsky.feed.getPostThread
            // For now, return mock data
            
            // Try to get the post from cache first
            var fetchedRootPost = await postCache.getPost(uri: postUri)
            
            // If not in cache, generate a mock post
            if fetchedRootPost == nil {
                fetchedRootPost = Post.createTextPost(
                    author: mockAuthors[0],
                    text: "This is the main post in the thread. What do you all think?",
                    createdAt: Date().addingTimeInterval(-3600)
                )
            }
            
            guard let mainPost = fetchedRootPost else {
                throw ThreadError.postNotFound
            }
            
            // Generate mock replies
            let fetchedReplies = MockDataGenerator.generateThreadReplies(to: mainPost, count: 10)
            
            // Cache all posts
            await postCache.cachePost(mainPost)
            await postCache.cachePosts(fetchedReplies)
            
            // Cache authors
            let allAuthors = [mainPost.author] + fetchedReplies.map { $0.author }
            await profileCache.cacheProfiles(allAuthors)
            
            // Update internal state - store URIs and refresh from cache
            self.parentPostUris = []  // No parents for now in mock
            self.replyPostUris = fetchedReplies.map { $0.uri }
            await self.refreshPostsFromCache()
        } catch {
            self.error = error
        }
    }
    
    /// Fetch more replies (pagination within thread)
    func loadMoreReplies() async {
        guard let cursor = repliesCursor, hasMoreReplies, !isLoadingMoreReplies, !isLoading else {
            return
        }
        
        isLoadingMoreReplies = true
        defer { isLoadingMoreReplies = false }
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // TODO: Replace with actual API call
            // For now, return empty (no more replies in mock)
            
            // Update state
            self.repliesCursor = nil
            self.hasMoreReplies = false
        } catch {
            // Error handling
        }
    }
    
    /// Refresh thread (pull to refresh)
    func refresh() async {
        // Clear state and fetch fresh
        self.repliesCursor = nil
        self.hasMoreReplies = true
        
        await fetchThread()
    }
    
    /// Reset state
    func reset() {
        parentPostUris = []
        replyPostUris = []
        rootPost = nil
        parentPosts = []
        replies = []
        repliesCursor = nil
        hasMoreReplies = true
    }
    
    /// Check if there are more replies to load
    var canLoadMoreReplies: Bool {
        return hasMoreReplies && repliesCursor != nil
    }
    
    // MARK: - Supporting Types
    
    enum ThreadError: Error {
        case postNotFound
        case invalidUri
    }
}

