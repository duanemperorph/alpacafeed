//
//  ThreadRepository.swift
//  AlpacaList
//
//  Repository for fetching and managing post threads
//

import Foundation

/// Repository for thread operations
class ThreadRepository {
    private let postCache: PostCache
    private let profileCache: ProfileCache
    
    init(postCache: PostCache, profileCache: ProfileCache) {
        self.postCache = postCache
        self.profileCache = profileCache
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch a post thread (main post + parents + replies)
    func fetchThread(postUri: String, depth: Int = 6) async throws -> ThreadData {
        // TODO: Replace with actual API call to app.bsky.feed.getPostThread
        // For now, return mock data
        
        // Try to get the post from cache first
        var rootPost = await postCache.getPost(uri: postUri)
        
        // If not in cache, generate a mock post
        if rootPost == nil {
            rootPost = Post.createTextPost(
                author: mockAuthors[0],
                text: "This is the main post in the thread. What do you all think?",
                createdAt: Date().addingTimeInterval(-3600)
            )
        }
        
        guard let mainPost = rootPost else {
            throw ThreadError.postNotFound
        }
        
        // Generate mock replies
        let replies = MockDataGenerator.generateThreadReplies(to: mainPost, count: 10)
        
        // Cache all posts
        await postCache.cachePost(mainPost)
        await postCache.cachePosts(replies)
        
        // Cache authors
        let allAuthors = [mainPost.author] + replies.map { $0.author }
        await profileCache.cacheProfiles(allAuthors)
        
        return ThreadData(
            rootPost: mainPost,
            parentPosts: [],  // No parents for now in mock
            replies: replies
        )
    }
    
    /// Fetch more replies (pagination within thread)
    func fetchMoreReplies(postUri: String, cursor: String?, limit: Int = 20) async throws -> (replies: [Post], cursor: String?) {
        // TODO: Replace with actual API call
        // For now, return empty (no more replies)
        
        return ([], nil)
    }
    
    // MARK: - Supporting Types
    
    struct ThreadData {
        let rootPost: Post
        let parentPosts: [Post]
        let replies: [Post]
    }
    
    enum ThreadError: Error {
        case postNotFound
        case invalidUri
    }
}

