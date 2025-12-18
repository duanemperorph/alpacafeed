//
//  FeedRepositoryCoordinator.swift
//  AlpacaList
//
//  Coordinates individual FeedRepository instances per feed type
//

import Foundation

/// Coordinates multiple FeedRepository instances, one per feed
@MainActor
class FeedRepositoryCoordinator {
    private let postCache: PostCache
    private let profileCache: ProfileCache
    private let feedService: FeedService
    
    // Cache of repository instances per feed
    private var repositories: [String: FeedRepository] = [:]
    private let lock = NSLock()
    
    init(postCache: PostCache, profileCache: ProfileCache, feedService: FeedService) {
        self.postCache = postCache
        self.profileCache = profileCache
        self.feedService = feedService
    }
    
    /// Get or create a repository for a specific feed type
    func repository(for feedType: FeedRepository.FeedType) -> FeedRepository {
        let feedId = feedType.feedId
        
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = repositories[feedId] {
            return existing
        }
        
        // Create new repository for this feed
        let repository = FeedRepository(
            feedType: feedType,
            postCache: postCache,
            profileCache: profileCache,
            feedService: feedService
        )
        repositories[feedId] = repository
        return repository
    }
    
    /// Clear all repositories (useful for logout)
    func clearAll() {
        lock.lock()
        defer { lock.unlock() }
        
        repositories.removeAll()
    }
    
    /// Remove repository for specific feed (useful for refresh)
    func remove(feedType: FeedRepository.FeedType) {
        lock.lock()
        defer { lock.unlock() }
        
        repositories.removeValue(forKey: feedType.feedId)
    }
    
    /// Get all active feed types
    var activeFeedTypes: [String] {
        lock.lock()
        defer { lock.unlock() }
        
        return Array(repositories.keys)
    }
}

