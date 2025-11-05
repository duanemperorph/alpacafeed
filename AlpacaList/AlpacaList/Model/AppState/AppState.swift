//
//  AppState.swift
//  AlpacaList
//
//  Central application state manager
//  Holds navigation, repositories, caches, and provides ViewModel factories
//

import Foundation
import Observation

/// Central application state manager
/// - Manages global app state (auth, navigation, etc.)
/// - Owns caches and long-lived coordinators
/// - Provides ViewModel factory methods that create fresh repositories
@Observable
class AppState {
    // MARK: - Navigation
    
    let navigationCoordinator: NavigationCoordinator
    
    // MARK: - Caches (Shared, long-lived)
    
    let postCache: PostCache
    let profileCache: ProfileCache
    
    // MARK: - Coordinators (Cached, manage repository instances)
    
    let feedRepositoryCoordinator: FeedRepositoryCoordinator
    
    // MARK: - Global State
    
    var currentUser: Author?
    var isAuthenticated: Bool = false
    
    // MARK: - Initialization
    
    init() {
        // Initialize caches
        self.postCache = PostCache()
        self.profileCache = ProfileCache()
        
        // Initialize feed repository coordinator
        self.feedRepositoryCoordinator = FeedRepositoryCoordinator(
            postCache: postCache,
            profileCache: profileCache
        )
        
        // Initialize navigation coordinator
        self.navigationCoordinator = NavigationCoordinator()
        
        // Set mock current user for now
        self.currentUser = mockAuthors[0]
        self.isAuthenticated = true
    }
    
    // MARK: - ViewModel Factory Methods
    
    // NOTE: These factory methods create FRESH repository instances per ViewModel
    // Only caches and coordinators are shared/long-lived
    
    /// Create a TimelineViewModel with proper dependencies
    /// TODO: Phase 4 - Update when TimelineViewModel accepts repositories
    func makeTimelineViewModel(type: TimelineViewModel.TimelineType) -> TimelineViewModel {
        // For now, use the existing initializer
        // Will be updated in Phase 4 to pass feedRepositoryCoordinator
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
    
    // MARK: - Private Helper Methods
    
    /// Create a fresh ThreadRepository instance
    private func makeThreadRepository() -> ThreadRepository {
        return ThreadRepository(postCache: postCache, profileCache: profileCache)
    }
    
    /// Create a fresh PostRepository instance
    private func makePostRepository() -> PostRepository {
        return PostRepository(postCache: postCache)
    }
    
    // MARK: - Cache Management
    
    /// Clear all caches
    func clearAllCaches() async {
        await postCache.clear()
        await profileCache.clear()
    }
    
    /// Get a cached post by URI
    func getCachedPost(uri: String) async -> Post? {
        return await postCache.getPost(uri: uri)
    }
    
    /// Get a cached profile by handle
    func getCachedProfile(handle: String) async -> Author? {
        return await profileCache.getProfile(handle: handle)
    }
    
    // MARK: - Coordinator Management
    
    /// Clear all feed repositories (useful for account switch)
    func clearAllFeedRepositories() {
        feedRepositoryCoordinator.clearAll()
    }
    
    // MARK: - Authentication (Mock for now)
    
    /// Mock login
    func login(identifier: String, password: String) async throws {
        // TODO: Implement actual authentication
        // For now, just set mock user
        currentUser = mockAuthors[0]
        isAuthenticated = true
    }
    
    /// Logout
    func logout() async {
        currentUser = nil
        isAuthenticated = false
        await clearAllCaches()
        clearAllFeedRepositories()
    }
}

