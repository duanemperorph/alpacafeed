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
@MainActor
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
    func makeTimelineViewModel(type: TimelineViewModel.TimelineType) -> TimelineViewModel {
        // Create fresh repository instances for this ViewModel
        let feedCoordinator = makeFeedRepositoryCoordinator()
        let postRepository = makePostRepository()
        
        return TimelineViewModel(
            timelineType: type,
            feedCoordinator: feedCoordinator,
            postRepository: postRepository
        )
    }
    
    /// Create a ThreadViewModel with proper dependencies
    func makeThreadViewModel(post: Post) -> ThreadViewModel {
        // Create fresh repository instances for this ViewModel
        let threadRepository = makeThreadRepository(postUri: post.uri)
        let postRepository = makePostRepository()
        
        return ThreadViewModel(
            threadRepository: threadRepository,
            postRepository: postRepository
        )
    }
    
    /// Create a ComposeViewModel with proper dependencies
    func makeComposeViewModel(
        replyTo: Post? = nil,
        onPostCreated: @escaping (Post) -> Void = { _ in }
    ) -> ComposeViewModel {
        // Create fresh PostRepository instance for this ViewModel
        let postRepository = makePostRepository()
        
        return ComposeViewModel(
            replyTo: replyTo,
            postRepository: postRepository,
            onPostCreated: onPostCreated
        )
    }
    
    // MARK: - Repository Factory Methods
    
    /// Create a fresh FeedRepositoryCoordinator instance
    func makeFeedRepositoryCoordinator() -> FeedRepositoryCoordinator {
        return FeedRepositoryCoordinator(postCache: postCache, profileCache: profileCache)
    }
    
    /// Create a fresh ThreadRepository instance for a specific thread
    func makeThreadRepository(postUri: String) -> ThreadRepository {
        return ThreadRepository(postUri: postUri, postCache: postCache, profileCache: profileCache)
    }
    
    /// Create a fresh PostRepository instance
    func makePostRepository() -> PostRepository {
        return PostRepository(postCache: postCache)
    }
}

