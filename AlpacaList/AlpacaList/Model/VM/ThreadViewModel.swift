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
class ThreadViewModel {
    // MARK: - Properties
    
    var rootPost: Post?           // The main post being viewed
    var parentPosts: [Post] = []  // Chain from main post to thread root
    var replies: [Post] = []      // Direct replies to the main post
    var isLoading = false
    var isLoadingMoreReplies = false
    var error: Error?
    
    // MARK: - Private Properties
    
    private let postUri: String
    private var repliesCursor: String?
    private var hasMoreReplies = true
    
    // Repository dependencies
    private let threadRepository: ThreadRepository?
    private let postRepository: PostRepository?
    
    // MARK: - Initialization
    
    /// Modern initializer with repository dependencies
    init(
        post: Post,
        threadRepository: ThreadRepository,
        postRepository: PostRepository
    ) {
        self.postUri = post.uri
        self.rootPost = post
        self.threadRepository = threadRepository
        self.postRepository = postRepository
    }
    
    /// Legacy initializer for backward compatibility (will be removed)
    init(postUri: String) {
        self.postUri = postUri
        self.threadRepository = nil
        self.postRepository = nil
    }
    
    /// Legacy convenience initializer for backward compatibility (will be removed)
    convenience init(post: Post) {
        self.init(postUri: post.uri)
        self.rootPost = post
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch the thread (main post + context + replies)
    func fetchThread(depth: Int = 6) {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        // TODO: Replace with actual API call to app.bsky.feed.getPostThread
        // For now, simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // If we don't have the post yet, set it
            if self.rootPost == nil {
                // TODO: Get from API response
            }
            
            self.isLoading = false
        }
    }
    
    /// Load more replies (pagination)
    func fetchMoreReplies() {
        guard !isLoadingMoreReplies, hasMoreReplies else {
            return
        }
        
        isLoadingMoreReplies = true
        
        // TODO: Replace with actual API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoadingMoreReplies = false
        }
    }
    
    /// Refresh thread
    func refresh() async {
        repliesCursor = nil
        hasMoreReplies = true
        
        await MainActor.run {
            self.parentPosts = []
            self.replies = []
        }
        
        fetchThread()
    }
    
    // MARK: - Interaction Methods
    
    /// Like a post (root or reply)
    func likePost(uri: String) {
        // Update the appropriate post
        if rootPost?.uri == uri {
            guard var post = rootPost else { return }
            
            if post.isLiked {
                post.isLiked = false
                post.likeCount = max(0, post.likeCount - 1)
                post.likeUri = nil
            } else {
                post.isLiked = true
                post.likeCount += 1
            }
            
            rootPost = post
        } else if let index = replies.firstIndex(where: { $0.uri == uri }) {
            var post = replies[index]
            
            if post.isLiked {
                post.isLiked = false
                post.likeCount = max(0, post.likeCount - 1)
                post.likeUri = nil
            } else {
                post.isLiked = true
                post.likeCount += 1
            }
            
            replies[index] = post
        } else if let index = parentPosts.firstIndex(where: { $0.uri == uri }) {
            var post = parentPosts[index]
            
            if post.isLiked {
                post.isLiked = false
                post.likeCount = max(0, post.likeCount - 1)
                post.likeUri = nil
            } else {
                post.isLiked = true
                post.likeCount += 1
            }
            
            parentPosts[index] = post
        }
        
        // TODO: API call to create/delete like
    }
    
    /// Repost a post
    func repost(uri: String) {
        // Similar to likePost but for reposts
        if rootPost?.uri == uri {
            guard var post = rootPost else { return }
            
            if post.isReposted {
                post.isReposted = false
                post.repostCount = max(0, post.repostCount - 1)
                post.repostUri = nil
            } else {
                post.isReposted = true
                post.repostCount += 1
            }
            
            rootPost = post
        } else if let index = replies.firstIndex(where: { $0.uri == uri }) {
            var post = replies[index]
            
            if post.isReposted {
                post.isReposted = false
                post.repostCount = max(0, post.repostCount - 1)
                post.repostUri = nil
            } else {
                post.isReposted = true
                post.repostCount += 1
            }
            
            replies[index] = post
        }
        
        // TODO: API call to create/delete repost
    }
    
    /// Reply to a post
    func reply(to uri: String, text: String) {
        // TODO: API call to create reply post
        // After success, refresh thread or add reply optimistically
    }
    
    /// Delete own post/reply
    func deletePost(uri: String) {
        // TODO: API call to delete post
        
        // Remove from replies if it's there
        replies.removeAll { $0.uri == uri }
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
    
    // MARK: - Mock Data (for testing)
    
    static func withMockData(for post: Post? = nil) -> ThreadViewModel {
        // Create main post
        let mainPost = post ?? Post.createTextPost(
            author: mockAuthors[0],
            text: "This is the main post in the thread. What do you all think?",
            createdAt: Date().addingTimeInterval(-3600)
        )
        
        let vm = ThreadViewModel(post: mainPost)
        
        // Generate mock replies
        vm.replies = MockDataGenerator.generateThreadReplies(to: mainPost, count: 10)
        
        return vm
    }
}

