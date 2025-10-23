//
//  TimelineViewModel.swift
//  AlpacaList
//
//  Timeline feed view model (replaces PostsListViewModel)
//

import Foundation
import Combine

/// View model for timeline/feed views (home, profile, custom feeds)
class TimelineViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: Error?
    
    // MARK: - Private Properties
    
    private var cursor: String?
    private var hasMorePosts = true
    private var cancellables = Set<AnyCancellable>()
    
    // Timeline type
    enum TimelineType {
        case home                          // User's home feed
        case authorFeed(handle: String)    // Specific author's posts
        case customFeed(uri: String)       // Algorithm feed
    }
    
    private let timelineType: TimelineType
    
    // MARK: - Initialization
    
    init(timelineType: TimelineType = .home) {
        self.timelineType = timelineType
    }
    
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
        let mockPosts = MockDataGenerator.generateTimeline()
        
        vm.posts = mockPosts
        
        return vm
    }
}

// MARK: - Mock Data Generator Extension

extension MockDataGenerator {
    /// Generate mock Bluesky timeline
    static func generateTimeline(count: Int = 20) -> [Post] {
        let authors = mockAuthors
        var posts: [Post] = []
        
        for i in 0..<count {
            let author = authors[i % authors.count]
            let date = Date().addingTimeInterval(-Double(i * 3600)) // Posts spread over time
            
            // Mix different post types
            let post: Post
            
            switch i % 5 {
            case 0:
                // Text only post
                post = Post.createTextPost(
                    author: author,
                    text: mockPostTexts[i % mockPostTexts.count],
                    createdAt: date
                )
                
            case 1:
                // Post with image
                post = Post.createImagePost(
                    author: author,
                    text: "Check out this alpaca! 🦙",
                    images: [
                        Embed.ImageEmbed(
                            thumb: "alpaca\((i % 8) + 1)",
                            fullsize: "alpaca\((i % 8) + 1)",
                            alt: "An adorable alpaca",
                            aspectRatio: Embed.AspectRatio(width: 16, height: 9)
                        )
                    ],
                    createdAt: date
                )
                
            case 2:
                // Post with link
                post = Post(
                    uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
                    cid: "bafyrei\(UUID().uuidString.prefix(16))",
                    author: author,
                    createdAt: date,
                    text: "Interesting article about alpacas",
                    embed: .external(Embed.ExternalEmbed(
                        uri: "https://example.com/alpacas",
                        title: "The Ultimate Guide to Alpacas",
                        description: "Everything you need to know about these amazing animals",
                        thumb: "alpaca1"
                    )),
                    likeCount: Int.random(in: 0...100),
                    repostCount: Int.random(in: 0...50),
                    replyCount: Int.random(in: 0...20)
                )
                
            case 3:
                // Post with repost attribution
                let repostedBy = authors[(i + 1) % authors.count]
                post = Post(
                    uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
                    cid: "bafyrei\(UUID().uuidString.prefix(16))",
                    author: author,
                    createdAt: date,
                    text: mockPostTexts[(i + 5) % mockPostTexts.count],
                    likeCount: Int.random(in: 0...100),
                    repostCount: Int.random(in: 0...50),
                    replyCount: Int.random(in: 0...20),
                    repostedBy: repostedBy
                )
                
            default:
                // Regular post with engagement
                post = Post(
                    uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
                    cid: "bafyrei\(UUID().uuidString.prefix(16))",
                    author: author,
                    createdAt: date,
                    text: mockPostTexts[i % mockPostTexts.count],
                    likeCount: Int.random(in: 0...100),
                    repostCount: Int.random(in: 0...50),
                    replyCount: Int.random(in: 0...20)
                )
            }
            
            posts.append(post)
        }
        
        return posts
    }
    
    static var mockAuthors: [Author] {
        [
            Author(did: "did:plc:alice123", handle: "alice.bsky.social", displayName: "Alice Anderson", avatar: "alpaca1"),
            Author(did: "did:plc:bob456", handle: "bob.bsky.social", displayName: "Bob Builder", avatar: "alpaca2"),
            Author(did: "did:plc:carol789", handle: "carol.bsky.social", displayName: "Carol Chen", avatar: "alpaca3"),
            Author(did: "did:plc:dave012", handle: "dave.bsky.social", displayName: "Dave Davis", avatar: "alpaca4"),
            Author(did: "did:plc:eve345", handle: "eve.bsky.social", displayName: "Eve Evans", avatar: "alpaca5")
        ]
    }
    
    static var mockPostTexts: [String] {
        [
            "Just discovered this amazing community! 🎉",
            "Working on some exciting new projects today",
            "Beautiful sunset views from the mountains 🌄",
            "Coffee and coding - perfect combination ☕️💻",
            "Excited to share what I've been building!",
            "Learning something new every day 📚",
            "Weekend vibes are the best ✨",
            "Grateful for all the support from this community 💙",
            "Quick update: making great progress!",
            "Thoughts on the latest tech trends?",
            "Alpacas are the most underrated animals 🦙",
            "Pro tip: take breaks when coding!",
            "Loving the weather today 🌞",
            "Just finished reading an amazing book",
            "Looking forward to the weekend!",
            "Anyone else working on side projects?",
            "Celebrating small wins today 🎊",
            "The best things in life are free",
            "Remember to stay hydrated! 💧",
            "Good morning everyone! Hope you have a great day 🌅"
        ]
    }
}

