//
//  MockRepositories.swift
//  AlpacaList
//
//  Mock implementations of repositories for testing and backward compatibility
//

// TODO: DELETEME

import Foundation

// MARK: - Mock FeedRepositoryCoordinator

/// Mock coordinator that returns mock feed repositories
class MockFeedRepositoryCoordinator: FeedRepositoryCoordinator {
    init() {
        // Create temporary caches for mock data
        let postCache = PostCache()
        let profileCache = ProfileCache()
        super.init(postCache: postCache, profileCache: profileCache)
    }
}

// MARK: - Mock PostRepository

/// Mock post repository for testing and backward compatibility
class MockPostRepository: PostRepository {
    init() {
        // Create temporary cache for mock data
        let postCache = PostCache()
        super.init(postCache: postCache)
    }
}

// MARK: - Mock ThreadRepository

/// Mock thread repository for testing and backward compatibility
class MockThreadRepository: ThreadRepository {
    init() {
        // Create temporary caches for mock data
        let postCache = PostCache()
        let profileCache = ProfileCache()
        super.init(postCache: postCache, profileCache: profileCache)
    }
}

