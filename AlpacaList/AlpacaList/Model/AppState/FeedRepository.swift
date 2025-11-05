//
//  FeedRepository.swift
//  AlpacaList
//
//  Repository for fetching and managing a single timeline feed
//

import Foundation

/// Repository for a single timeline/feed
/// Each instance manages one specific feed and tracks its pagination state
class FeedRepository {
    private let postCache: PostCache
    private let profileCache: ProfileCache
    private let feedType: FeedType
    
    // Pagination state for this specific feed
    private var cursor: String?
    private var hasMore: Bool = true
    
    init(feedType: FeedType, postCache: PostCache, profileCache: ProfileCache) {
        self.feedType = feedType
        self.postCache = postCache
        self.profileCache = profileCache
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
    func fetchFeed(limit: Int = 20) async throws -> [Post] {
        // TODO: Replace with actual API call when ready
        // For now, return mock data
        
        let posts = MockDataGenerator.generateTimeline(count: limit)
        let newCursor = "mock_cursor_\(UUID().uuidString)"
        
        // Cache the posts and authors
        await postCache.cachePosts(posts)
        let authors = posts.map { $0.author }
        await profileCache.cacheProfiles(authors)
        
        // Store cursor for this feed
        self.cursor = newCursor
        self.hasMore = true
        
        return posts
    }
    
    /// Load more posts (pagination)
    func loadMore(limit: Int = 20) async throws -> [Post] {
        guard let currentCursor = cursor, hasMore else {
            return []
        }
        
        // TODO: Replace with actual API call using cursor
        // For now, return mock data
        
        let posts = MockDataGenerator.generateTimeline(count: limit)
        let newCursor = "mock_cursor_\(UUID().uuidString)"
        
        // Cache the posts and authors
        await postCache.cachePosts(posts)
        let authors = posts.map { $0.author }
        await profileCache.cacheProfiles(authors)
        
        // Update cursor
        self.cursor = newCursor
        
        return posts
    }
    
    /// Refresh feed (pull to refresh)
    func refresh(limit: Int = 20) async throws -> [Post] {
        // Clear cursor and fetch fresh
        self.cursor = nil
        self.hasMore = true
        
        return try await fetchFeed(limit: limit)
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
        cursor = nil
        hasMore = true
    }
}

