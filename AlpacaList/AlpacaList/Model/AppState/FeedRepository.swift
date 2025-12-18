//
//  FeedRepository.swift
//  AlpacaList
//
//  Repository for fetching and managing a single timeline feed
//

import Foundation
import Observation

/// Repository for a single timeline/feed
/// Each instance manages one specific feed and tracks its pagination state
@Observable
@MainActor
class FeedRepository {
    private let postCache: PostCache
    private let profileCache: ProfileCache
    private let feedService: FeedService
    private let feedType: FeedType
    
    // Feed state - stores URIs and cached posts
    private var postUris: [String] = []
    private(set) var posts: [Post] = []
    
    /// Refresh posts from cache - call this to get latest post states
    func refreshPostsFromCache() async {
        posts = await postCache.getPosts(uris: postUris)
    }
    
    // Loading states
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    
    // Error state for feed operations
    private(set) var error: Error?
    
    // Pagination state for this specific feed
    private var cursor: String?
    private var hasMore: Bool = true
    
    init(feedType: FeedType, postCache: PostCache, profileCache: ProfileCache, feedService: FeedService) {
        self.feedType = feedType
        self.postCache = postCache
        self.profileCache = profileCache
        self.feedService = feedService
    }
    
    // MARK: - Feed Types
    
    enum FeedType: Hashable {
        case home
        case authorFeed(handle: String)
        case customFeed(uri: String)
        case likes(handle: String)
        case search(query: String)
        
        var feedId: String {
            switch self {
            case .home:
                return "home"
            case .authorFeed(let handle):
                return "author:\(handle)"
            case .customFeed(let uri):
                return "custom:\(uri)"
            case .likes(let handle):
                return "likes:\(handle)"
            case .search(let query):
                return "search:\(query)"
            }
        }
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch initial feed (resets pagination)
    func fetchFeed(limit: Int = 50) async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let response: TimelineResponse
            
            switch feedType {
            case .home:
                response = try await feedService.getTimeline(cursor: nil, limit: limit)
            case .customFeed(let uri):
                response = try await feedService.getFeed(feedUri: uri, cursor: nil, limit: limit)
            case .authorFeed, .likes, .search:
                // TODO: Implement these feed types
                return
            }
            
            // Convert DTOs to domain models
            let fetchedPosts = response.toPosts()
            
            // Cache the posts and authors
            await postCache.cachePosts(fetchedPosts)
            let authors = fetchedPosts.map { $0.author }
            await profileCache.cacheProfiles(authors)
            
            // Update internal state - store URIs and refresh from cache
            self.postUris = fetchedPosts.map { $0.uri }
            self.cursor = response.cursor
            self.hasMore = response.cursor != nil
            await self.refreshPostsFromCache()
        } catch {
            self.error = error
        }
    }
    
    /// Load more posts (pagination)
    func loadMore(limit: Int = 50) async {
        guard let currentCursor = cursor, hasMore, !isLoadingMore, !isLoading else {
            return
        }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            let response: TimelineResponse
            
            switch feedType {
            case .home:
                response = try await feedService.getTimeline(cursor: currentCursor, limit: limit)
            case .customFeed(let uri):
                response = try await feedService.getFeed(feedUri: uri, cursor: currentCursor, limit: limit)
            case .authorFeed, .likes, .search:
                // TODO: Implement these feed types
                return
            }
            
            // Convert DTOs to domain models
            let morePosts = response.toPosts()
            
            // Cache the posts and authors
            await postCache.cachePosts(morePosts)
            let authors = morePosts.map { $0.author }
            await profileCache.cacheProfiles(authors)
            
            // Append URIs to internal state and refresh from cache
            self.postUris.append(contentsOf: morePosts.map { $0.uri })
            self.cursor = response.cursor
            self.hasMore = response.cursor != nil
            await self.refreshPostsFromCache()
        } catch {
            self.error = error
        }
    }
    
    /// Refresh feed (pull to refresh)
    func refresh(limit: Int = 20) async {
        // Clear cursor and fetch fresh
        self.cursor = nil
        self.hasMore = true
        
        await fetchFeed(limit: limit)
    }
    
    // MARK: - State
    
    /// Check if there are more posts to load
    var canLoadMore: Bool {
        return hasMore && cursor != nil
    }
    
    /// Current cursor value
    var currentCursor: String? {
        return cursor
    }
    
    /// Reset pagination state
    func reset() {
        postUris = []
        cursor = nil
        hasMore = true
    }
    
    // MARK: - Post Mutations
    
    /// Update a post in the cache (post is already cached, no need to update URIs)
    func updatePost(_ post: Post) async {
        await postCache.updatePost(post)
    }
    
    /// Remove a post from the feed
    func removePost(uri: String) async {
        postUris.removeAll { $0 == uri }
        await postCache.removePost(uri: uri)
        await refreshPostsFromCache()
    }
    
    /// Insert a post at the beginning (for new posts)
    func prependPost(_ post: Post) async {
        postUris.insert(post.uri, at: 0)
        await postCache.cachePost(post)
        await refreshPostsFromCache()
    }
}

