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
    
    // Repository dependencies
    private let feedRepository: FeedRepository
    private let postRepository: PostRepository
    
    // MARK: - Initialization
    
    /// Initializer with repository dependencies
    init(
        feedRepository: FeedRepository,
        postRepository: PostRepository
    ) {
        self.feedRepository = feedRepository
        self.postRepository = postRepository
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
    /// Note: Quote posts require embed support which is not yet implemented
    func quotePost(uri: String, text: String) {
        // TODO: Implement quote posts once embed creation is supported
        // This requires creating a record embed and calling the API
        print("Quote post not yet implemented - requires embed support")
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
}

