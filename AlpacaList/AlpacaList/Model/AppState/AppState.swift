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
/// - Manages global app state (auth, caches, etc.)
/// - Owns shared caches and repositories (some repositories are created fresh per-ViewModel)
/// - Delegates ViewModel creation to ViewModelFactory
@Observable
@MainActor
class AppState {
    // MARK: - Repositories (Shared, long-lived)
    
    let authRepository: AuthenticationRepository
    
    // MARK: - API Services (Shared, long-lived)
    
    let apiClient: BSAPIClient
    let feedService: FeedService
    
    // MARK: - Caches (Shared, long-lived)
    
    let postCache: PostCache
    let profileCache: ProfileCache
    
    // MARK: - ViewModel Factory
    
    let viewModelFactory: ViewModelFactory
    
    // MARK: - Global State
    
    var currentUser: Author?
    
    /// Current feed type for the home timeline
    var currentFeedType: FeedType = .following
    
    /// Whether user is authenticated (delegated to AuthenticationRepository)
    var isAuthenticated: Bool {
        authRepository.isAuthenticated
    }
    
    /// Current user's handle (from authenticated session)
    var currentHandle: String? {
        authRepository.currentHandle
    }
    
    // MARK: - Initialization
    
    init() {
        // Initialize authentication repository
        self.authRepository = AuthenticationRepository()
        
        // Initialize API client and services
        self.apiClient = BSAPIClient(sessionRepository: authRepository)
        self.feedService = FeedService(apiService: apiClient)
        
        // Initialize caches
        self.postCache = PostCache()
        self.profileCache = ProfileCache()
        
        // Initialize ViewModel factory
        self.viewModelFactory = ViewModelFactory(
            postCache: postCache,
            profileCache: profileCache,
            feedService: feedService
        )
        
        // Set mock current user for now
        self.currentUser = mockAuthors[0]
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
    
    // MARK: - Authentication
    
    /// Restore session from secure storage on app launch
    func restoreSession() async {
        await authRepository.restoreSession()
        // TODO: Fetch current user profile from session
    }
    
    /// Login with identifier and password
    func login(identifier: String, password: String, server: String = "bsky.social") async throws {
        try await authRepository.login(identifier: identifier, password: password, server: server)
        // TODO: Fetch current user profile from session
        currentUser = mockAuthors[0]  // Mock for now
    }
    
    /// Logout and clear caches
    func logout() async {
        await authRepository.logout()
        currentUser = nil
        await clearAllCaches()
    }
}

