//
//  ViewModelFactory.swift
//  AlpacaList
//
//  Factory for creating ViewModels with proper dependencies
//

import Foundation

/// Factory for creating ViewModels with proper dependencies
/// - Creates FRESH repository instances per ViewModel
/// - Uses shared caches and services
@MainActor
class ViewModelFactory {
    // MARK: - Dependencies (Shared, long-lived)
    
    private let postCache: PostCache
    private let profileCache: ProfileCache
    private let feedService: FeedService
    
    // MARK: - Initialization
    
    init(
        postCache: PostCache,
        profileCache: ProfileCache,
        feedService: FeedService
    ) {
        self.postCache = postCache
        self.profileCache = profileCache
        self.feedService = feedService
    }
    
    // MARK: - ViewModel Factory Methods
    
    /// Create a TimelineViewModel for a UI feed type (Following, Discover, etc.)
    func makeTimelineViewModel(for feedType: FeedType) -> TimelineViewModel {
        let repositoryFeedType = mapToRepositoryFeedType(feedType)
        return makeTimelineViewModel(feedType: repositoryFeedType)
    }
    
    /// Create a TimelineViewModel with a specific repository feed type
    func makeTimelineViewModel(feedType: FeedRepository.FeedType) -> TimelineViewModel {
        // Create fresh repository instances for this ViewModel
        let feedRepository = makeFeedRepository(feedType: feedType)
        let postRepository = makePostRepository()
        
        return TimelineViewModel(
            feedRepository: feedRepository,
            postRepository: postRepository
        )
    }
    
    // MARK: - Feed Type Mapping
    
    /// Map UI FeedType to FeedRepository.FeedType
    private func mapToRepositoryFeedType(_ feedType: FeedType) -> FeedRepository.FeedType {
        switch feedType {
        case .following:
            return .home
        case .custom(let savedFeed):
            return .customFeed(uri: savedFeed.uri)
        }
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
    
    /// Create a fresh FeedRepository instance for a specific feed type
    func makeFeedRepository(feedType: FeedRepository.FeedType) -> FeedRepository {
        return FeedRepository(
            feedType: feedType,
            postCache: postCache,
            profileCache: profileCache,
            feedService: feedService
        )
    }
    
    /// Create a fresh ThreadRepository instance for a specific thread
    func makeThreadRepository(postUri: String) -> ThreadRepository {
        return ThreadRepository(
            postUri: postUri,
            postCache: postCache,
            profileCache: profileCache,
            feedService: feedService
        )
    }
    
    /// Create a fresh PostRepository instance
    func makePostRepository() -> PostRepository {
        return PostRepository(postCache: postCache, feedService: feedService)
    }
}

