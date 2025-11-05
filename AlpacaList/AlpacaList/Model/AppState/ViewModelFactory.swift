//
//  ViewModelFactory.swift
//  AlpacaList
//
//  Factory for creating ViewModels with proper dependencies
//

import Foundation

/// Factory for creating ViewModels with proper dependencies
/// - Creates FRESH repository and coordinator instances per ViewModel
/// - Uses shared caches only
class ViewModelFactory {
    // MARK: - Dependencies (Shared, long-lived)
    
    private let postCache: PostCache
    private let profileCache: ProfileCache
    
    // MARK: - Initialization
    
    init(
        postCache: PostCache,
        profileCache: ProfileCache
    ) {
        self.postCache = postCache
        self.profileCache = profileCache
    }
    
    // MARK: - ViewModel Factory Methods
    
    /// Create a TimelineViewModel with proper dependencies
    /// TODO: Phase 4 - Update when TimelineViewModel accepts repositories
    func makeTimelineViewModel(type: TimelineViewModel.TimelineType) -> TimelineViewModel {
        // For now, use the existing initializer
        // Will be updated in Phase 4 to pass fresh FeedRepositoryCoordinator
        return TimelineViewModel(timelineType: type)
    }
    
    /// Create a ThreadViewModel with proper dependencies
    /// TODO: Phase 4 - Update when ThreadViewModel accepts repositories
    func makeThreadViewModel(post: Post) -> ThreadViewModel {
        // For now, use the existing initializer
        // Will be updated in Phase 4 to pass fresh ThreadRepository
        return ThreadViewModel(post: post)
    }
    
    /// Create a ComposeViewModel with proper dependencies
    /// TODO: Phase 4 - Update when ComposeViewModel accepts repositories
    func makeComposeViewModel(replyTo: Post? = nil, onPostCreated: @escaping (Post) -> Void = { _ in }) -> ComposeViewModel {
        // For now, use the existing initializer
        // Will be updated in Phase 4 to pass fresh PostRepository
        return ComposeViewModel(replyTo: replyTo)
    }
    
    // MARK: - Repository Factory Methods
    
    /// Create a fresh FeedRepositoryCoordinator instance
    func makeFeedRepositoryCoordinator() -> FeedRepositoryCoordinator {
        return FeedRepositoryCoordinator(postCache: postCache, profileCache: profileCache)
    }
    
    /// Create a fresh ThreadRepository instance
    func makeThreadRepository() -> ThreadRepository {
        return ThreadRepository(postCache: postCache, profileCache: profileCache)
    }
    
    /// Create a fresh PostRepository instance
    func makePostRepository() -> PostRepository {
        return PostRepository(postCache: postCache)
    }
}

