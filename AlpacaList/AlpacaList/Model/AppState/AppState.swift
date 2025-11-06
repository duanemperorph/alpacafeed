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
/// - Owns shared caches only (repositories and coordinators are created fresh)
/// - Delegates ViewModel creation to ViewModelFactory
@Observable
@MainActor
class AppState {
    // MARK: - Navigation
    
    let navigationCoordinator: NavigationCoordinator
    
    // MARK: - Caches (Shared, long-lived)
    
    let postCache: PostCache
    let profileCache: ProfileCache
    
    // MARK: - ViewModel Factory
    
    let viewModelFactory: ViewModelFactory
    
    // MARK: - Global State
    
    var currentUser: Author?
    var isAuthenticated: Bool = false
    
    // MARK: - Initialization
    
    init() {
        // Initialize caches
        self.postCache = PostCache()
        self.profileCache = ProfileCache()
        
        // Initialize ViewModel factory
        self.viewModelFactory = ViewModelFactory(
            postCache: postCache,
            profileCache: profileCache
        )
        
        // Initialize navigation coordinator
        self.navigationCoordinator = NavigationCoordinator()
        
        // Set mock current user for now
        self.currentUser = mockAuthors[0]
        self.isAuthenticated = true
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
    }
}

