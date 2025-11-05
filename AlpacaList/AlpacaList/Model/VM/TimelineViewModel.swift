//
//  TimelineViewModel.swift
//  AlpacaList
//
//  Timeline feed view model (replaces PostsListViewModel)
//

import Foundation
import Observation

/// View model for timeline/feed views (home, profile, custom feeds)
///
/// NOTE: This ViewModel will be refactored in Phase 4 to use FeedRepositoryCoordinator
/// Pattern will be:
/// ```
/// class TimelineViewModel {
///     private let feedCoordinator: FeedRepositoryCoordinator
///     private let feedType: FeedRepository.FeedType
///     private var feedRepository: FeedRepository { 
///         feedCoordinator.repository(for: feedType)
///     }
/// }
/// ```
@Observable
class TimelineViewModel {
    // MARK: - Properties
    
    var posts: [Post] = []
    var isLoading = false
    var isLoadingMore = false
    var error: Error?
    
    // MARK: - Private Properties
    
    private var cursor: String?
    private var hasMorePosts = true
    
    // Timeline type
    enum TimelineType {
        case home                          // User's home feed
        case authorFeed(handle: String)    // Specific author's posts
        case customFeed(uri: String)       // Algorithm feed
        case likes(handle: String)         // User's liked posts
        case search(query: String)         // Search results
    }
    
    private let timelineType: TimelineType
    
    // MARK: - Initialization
    
    init(timelineType: TimelineType = .home) {
        self.timelineType = timelineType
    }
    
    // TODO: Phase 4 - Add this initializer:
    // init(
    //     timelineType: TimelineType,
    //     feedCoordinator: FeedRepositoryCoordinator,
    //     postRepository: PostRepository,
    //     navigationCoordinator: NavigationCoordinator
    // ) {
    //     self.timelineType = timelineType
    //     self.feedCoordinator = feedCoordinator
    //     self.postRepository = postRepository
    //     self.navigationCoordinator = navigationCoordinator
    //     
    //     // Get the appropriate feed repository for this timeline
    //     self.feedRepository = feedCoordinator.repository(for: mapToFeedType(timelineType))
    // }
    
    // MARK: - Fetch Methods
    
    /// Fetch timeline (initial load)
    func fetchTimeline() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        cursor = nil
        hasMorePosts = true
        
        // TODO: Replace with actual API call
        // For now, just clear posts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.posts = []
            self?.isLoading = false
        }
    }
    
    /// Load more posts (pagination)
    func loadMore() {
        guard !isLoadingMore, !isLoading, hasMorePosts, cursor != nil else {
            return
        }
        
        isLoadingMore = true
        
        // TODO: Replace with actual API call using cursor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoadingMore = false
        }
    }
    
    /// Refresh timeline (pull to refresh)
    func refresh() async {
        cursor = nil
        hasMorePosts = true
        
        // TODO: Replace with actual API call
        await MainActor.run {
            self.posts = []
        }
    }
    
    // MARK: - Interaction Methods
    
    /// Like a post
    func likePost(uri: String) {
        guard let index = posts.firstIndex(where: { $0.uri == uri }) else {
            return
        }
        
        var post = posts[index]
        
        if post.isLiked {
            // Unlike
            post.isLiked = false
            post.likeCount = max(0, post.likeCount - 1)
            post.likeUri = nil
            
            // TODO: API call to delete like record
        } else {
            // Like
            post.isLiked = true
            post.likeCount += 1
            
            // TODO: API call to create like record
            // Set post.likeUri from response
        }
        
        posts[index] = post
    }
    
    /// Repost a post
    func repost(uri: String) {
        guard let index = posts.firstIndex(where: { $0.uri == uri }) else {
            return
        }
        
        var post = posts[index]
        
        if post.isReposted {
            // Undo repost
            post.isReposted = false
            post.repostCount = max(0, post.repostCount - 1)
            post.repostUri = nil
            
            // TODO: API call to delete repost record
        } else {
            // Repost
            post.isReposted = true
            post.repostCount += 1
            
            // TODO: API call to create repost record
            // Set post.repostUri from response
        }
        
        posts[index] = post
    }
    
    /// Quote post (repost with comment)
    func quotePost(uri: String, text: String) {
        // TODO: API call to create quote post
        // This creates a new post with embed.record pointing to the quoted post
    }
    
    /// Delete own post
    func deletePost(uri: String) {
        // TODO: API call to delete post record
        // Remove from local array on success
        posts.removeAll { $0.uri == uri }
    }
    
    /// Bookmark a post (local only for now)
    func toggleBookmark(uri: String) {
        guard let index = posts.firstIndex(where: { $0.uri == uri }) else {
            return
        }
        
        posts[index].isBookmarked.toggle()
        
        // TODO: Persist bookmarks locally or via API
    }
    
    // MARK: - Mock Data (for testing)
    
    static func withMockData() -> TimelineViewModel {
        let vm = TimelineViewModel()
        
        // Generate mock posts
        vm.posts = MockDataGenerator.generateTimeline()
        
        return vm
    }
    
    // MARK: - Phase 4 Helper Methods (for future use)
    
    // TODO: Phase 4 - Add this helper to map between types:
    // private func mapToFeedType(_ timelineType: TimelineType) -> FeedRepository.FeedType {
    //     switch timelineType {
    //     case .home:
    //         return .home
    //     case .authorFeed(let handle):
    //         return .authorFeed(handle: handle)
    //     case .customFeed(let uri):
    //         return .customFeed(uri: uri)
    //     case .likes(let handle):
    //         return .likes(handle: handle)
    //     case .search(let query):
    //         return .search(query: query)
    //     }
    // }
}

