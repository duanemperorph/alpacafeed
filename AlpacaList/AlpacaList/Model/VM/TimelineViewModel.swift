//
//  TimelineViewModel.swift
//  AlpacaList
//
//  Timeline feed view model (replaces PostsListViewModel)
//

import Foundation
import Observation

/// View model for timeline/feed views (home, profile, custom feeds)
@Observable
@MainActor
class TimelineViewModel {
    // MARK: - Properties
    
    /// Posts for the current timeline - computed from repository (single source of truth)
    var posts: [Post] {
        return feedRepository.posts
    }
    
    /// Loading states - computed from repository (single source of truth)
    var isLoading: Bool {
        return feedRepository.isLoading
    }
    
    var isLoadingMore: Bool {
        return feedRepository.isLoadingMore
    }
    
    // MARK: - Private Properties
    
    // Timeline type
    enum TimelineType: Equatable {
        case home                          // User's home feed
        case authorFeed(handle: String)    // Specific author's posts
        case customFeed(uri: String)       // Algorithm feed
        case likes(handle: String)         // User's liked posts
        case search(query: String)         // Search results
    }
    
    private(set) var timelineType: TimelineType  // Changed to var to support switching
    
    // Repository dependencies
    private let feedCoordinator: FeedRepositoryCoordinator
    private let postRepository: PostRepository
    
    // Computed property to get the feed repository for this timeline
    private var feedRepository: FeedRepository {
        return feedCoordinator.repository(for: mapToFeedType(timelineType))
    }
    
    // MARK: - Initialization
    
    /// Initializer with repository dependencies
    init(
        timelineType: TimelineType,
        feedCoordinator: FeedRepositoryCoordinator,
        postRepository: PostRepository
    ) {
        self.timelineType = timelineType
        self.feedCoordinator = feedCoordinator
        self.postRepository = postRepository
    }
    
    // MARK: - Timeline Switching
    
    /// Switch to a different timeline type
    /// This allows the same ViewModel to display different feeds without recreating it
    func switchTimeline(to newType: TimelineType) {
        guard newType != timelineType else { return }
        
        // Update the timeline type
        timelineType = newType
        
        // Note: The feedRepository computed property will now return a different repository
        // from the coordinator based on the new timeline type, and posts will automatically
        // reflect the new repository's state
        
        // Fetch the new timeline
        fetchTimeline()
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch timeline (initial load)
    func fetchTimeline() {
        Task {
            await feedRepository.fetchFeed()
        }
    }
    
    /// Load more posts (pagination)
    func loadMore() {
        Task {
            await feedRepository.loadMore()
        }
    }
    
    /// Refresh timeline (pull to refresh)
    func refresh() async {
        await feedRepository.refresh()
    }
    
    // MARK: - Interaction Methods
    
    /// Like a post
    func likePost(uri: String) {
        Task {
            guard let post = posts.first(where: { $0.uri == uri }) else { return }
            
            // PostRepository handles optimistic update in cache
            if post.isLiked {
                await postRepository.unlikePost(uri: uri)
            } else {
                await postRepository.likePost(uri: uri)
            }
            
            // Refresh posts from cache to show updated state
            await feedRepository.refreshPostsFromCache()
        }
    }
    
    /// Repost a post
    func repost(uri: String) {
        Task {
            guard let post = posts.first(where: { $0.uri == uri }) else { return }
            
            // PostRepository handles optimistic update in cache
            if post.isReposted {
                await postRepository.deleteRepost(uri: uri)
            } else {
                await postRepository.repost(uri: uri)
            }
            
            // Refresh posts from cache to show updated state
            await feedRepository.refreshPostsFromCache()
        }
    }
    
    /// Quote post (repost with comment)
    func quotePost(uri: String, text: String) {
        guard let quotedPost = posts.first(where: { $0.uri == uri }) else {
            return
        }
        
        // Create a record embed for the quoted post
        let recordEmbed = Embed.RecordEmbed(
            uri: quotedPost.uri,
            cid: quotedPost.cid
        )
        
        Task {
            if let newPost = await postRepository.createPost(
                text: text,
                replyTo: nil,
                embed: .record(recordEmbed)
            ) {
                // Add the new quote post to the timeline via repository
                await self.feedRepository.prependPost(newPost)
            }
        }
    }
    
    /// Delete own post
    func deletePost(uri: String) {
        Task {
            // Remove from repository and cache
            await feedRepository.removePost(uri: uri)
            
            // Delete via API
            _ = await postRepository.deletePost(uri: uri)
        }
    }
    
    /// Bookmark a post (local only for now)
    func toggleBookmark(uri: String) {
        Task {
            guard let post = posts.first(where: { $0.uri == uri }) else {
                return
            }
            
            var updatedPost = post
            updatedPost.isBookmarked.toggle()
            await feedRepository.updatePost(updatedPost)
            
            // TODO: Persist bookmarks locally or via API
        }
    }
    
    // MARK: - Helper Methods
    
    /// Map TimelineType to FeedRepository.FeedType
    private func mapToFeedType(_ timelineType: TimelineType) -> FeedRepository.FeedType {
        switch timelineType {
        case .home:
            return .home
        case .authorFeed(let handle):
            return .authorFeed(handle: handle)
        case .customFeed(let uri):
            return .customFeed(uri: uri)
        case .likes(let handle):
            return .likes(handle: handle)
        case .search(let query):
            return .search(query: query)
        }
    }
}

