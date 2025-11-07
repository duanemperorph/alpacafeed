//
//  ThreadViewModel.swift
//  AlpacaList
//
//  Thread view model (replaces CommentsListViewModel)
//

import Foundation
import Observation

/// View model for post thread view (linear, not nested tree)
@Observable
@MainActor
class ThreadViewModel {
    // MARK: - Properties (computed from repository - single source of truth)
    
    var rootPost: Post? {
        return threadRepository.rootPost
    }
    
    var parentPosts: [Post] {
        return threadRepository.parentPosts
    }
    
    var replies: [Post] {
        return threadRepository.replies
    }
    
    var isLoading: Bool {
        return threadRepository.isLoading
    }
    
    var isLoadingMoreReplies: Bool {
        return threadRepository.isLoadingMoreReplies
    }
    
    var error: Error? {
        return threadRepository.error
    }
    
    // MARK: - Private Properties
    
    // Repository dependencies
    private let threadRepository: ThreadRepository
    private let postRepository: PostRepository
    
    // MARK: - Initialization
    
    /// Initializer with repository dependencies
    init(
        threadRepository: ThreadRepository,
        postRepository: PostRepository
    ) {
        self.threadRepository = threadRepository
        self.postRepository = postRepository
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch the thread (main post + context + replies)
    func fetchThread(depth: Int = 6) {
        Task {
            await threadRepository.fetchThread(depth: depth)
        }
    }
    
    /// Load more replies (pagination)
    func fetchMoreReplies() {
        Task {
            await threadRepository.loadMoreReplies()
        }
    }
    
    /// Refresh thread
    func refresh() async {
        await threadRepository.refresh()
    }
    
    // MARK: - Interaction Methods
    
    /// Like a post (root or reply)
    func likePost(uri: String) {
        Task {
            guard let post = findPost(by: uri) else { return }
            
            // PostRepository handles optimistic update in cache
            if post.isLiked {
                await postRepository.unlikePost(uri: uri)
            } else {
                await postRepository.likePost(uri: uri)
            }
            
            // Refresh posts from cache to show updated state
            await threadRepository.refreshPostsFromCache()
        }
    }
    
    /// Repost a post
    func repost(uri: String) {
        Task {
            guard let post = findPost(by: uri) else { return }
            
            // PostRepository handles optimistic update in cache
            if post.isReposted {
                await postRepository.deleteRepost(uri: uri)
            } else {
                await postRepository.repost(uri: uri)
            }
            
            // Refresh posts from cache to show updated state
            await threadRepository.refreshPostsFromCache()
        }
    }
    
    /// Reply to a post
    func reply(to uri: String, text: String) {
        Task {
            guard let post = findPost(by: uri) else { return }
            
            // Create reply via PostRepository
            if let newReply = await postRepository.createPost(text: text, replyTo: post) {
                // TODO: Add the new reply to the thread
                // For now, just refresh the whole thread
                await threadRepository.refresh()
            }
        }
    }
    
    /// Delete own post/reply
    func deletePost(uri: String) {
        Task {
            // Delete via API
            _ = await postRepository.deletePost(uri: uri)
            
            // Refresh thread to reflect deletion
            await threadRepository.refresh()
        }
    }
    
    // MARK: - Computed Properties
    
    /// All posts in thread (for rendering)
    var allPosts: [Post] {
        var posts: [Post] = []
        
        // Add parent chain (if any)
        posts.append(contentsOf: parentPosts)
        
        // Add main post
        if let root = rootPost {
            posts.append(root)
        }
        
        // Add replies
        posts.append(contentsOf: replies)
        
        return posts
    }
    
    /// Is this a reply thread (has parents)?
    var isReplyThread: Bool {
        !parentPosts.isEmpty
    }
    
    // MARK: - Private Helper Methods
    
    /// Find a post by URI in rootPost, parentPosts, or replies
    private func findPost(by uri: String) -> Post? {
        return [rootPost].compactMap({ $0 }).first(where: { $0.uri == uri })
            ?? parentPosts.first(where: { $0.uri == uri })
            ?? replies.first(where: { $0.uri == uri })
    }
}

