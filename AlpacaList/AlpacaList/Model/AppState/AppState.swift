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
    
    // MARK: - Feed Repositories
    
    let savedFeedsRepository: SavedFeedsRepository
    let followsRepository: FollowsRepository
    
    // MARK: - ViewModel Factory
    
    let viewModelFactory: ViewModelFactory
    
    // MARK: - Navigation
    
    let navigationCoordinator: NavigationCoordinator
    
    // MARK: - Global State
    
    var currentUser: Author?
    
    /// Whether session restoration has completed (not whether user is authenticated)
    private(set) var isSessionRestored: Bool = false
    
    /// Whether user is authenticated (delegated to AuthenticationRepository)
    var isAuthenticated: Bool {
        authRepository.isAuthenticated
    }
    
    /// Current user's handle (from authenticated session)
    var currentHandle: String? {
        authRepository.currentHandle
    }
    
    /// All authenticated sessions
    var allAccounts: [AuthSession] {
        authRepository.allSessions
    }
    
    /// Number of authenticated accounts
    var accountCount: Int {
        authRepository.accountCount
    }
    
    /// The DID of the currently active account
    var activeAccountDID: String? {
        authRepository.activeAccountDID
    }
    
    // MARK: - Initialization
    
    init() {
        // Initialize authentication repository
        self.authRepository = AuthenticationRepository()
        
        // Initialize API client and services
        self.apiClient = BSAPIClient(sessionRepository: authRepository)
        self.feedService = FeedService(apiService: apiClient)
        
        // Initialize caches (ProfileCache first since PostCache depends on it)
        self.profileCache = ProfileCache()
        self.postCache = PostCache(profileCache: profileCache)
        
        // Initialize feed repositories
        self.savedFeedsRepository = SavedFeedsRepository(feedService: feedService)
        self.followsRepository = FollowsRepository(feedService: feedService, postCache: postCache)
        
        // Initialize ViewModel factory
        self.viewModelFactory = ViewModelFactory(
            postCache: postCache,
            profileCache: profileCache,
            feedService: feedService,
            followsRepository: followsRepository
        )
        
        // Initialize navigation coordinator (depends on viewModelFactory)
        self.navigationCoordinator = NavigationCoordinator(viewModelFactory: viewModelFactory)
        
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
        isSessionRestored = true
        
        // Fetch saved feeds and follows if authenticated
        if isAuthenticated {
            await savedFeedsRepository.fetchSavedFeeds()
            await followsRepository.fetchFollows()
        }
    }
    
    /// Login with identifier and password
    func login(identifier: String, password: String, server: String = "bsky.social") async throws {
        try await authRepository.login(identifier: identifier, password: password, server: server)
        
        // Fetch saved feeds and follows after login
        await savedFeedsRepository.fetchSavedFeeds()
        await followsRepository.fetchFollows()
        
        currentUser = mockAuthors[0]  // Mock for now
    }
    
    /// Logout a specific account by DID
    func logout(did: String) async {
        let wasActive = isActiveAccount(did: did)
        await authRepository.logout(did: did)
        
        // If no accounts remaining, clear everything
        if !isAuthenticated {
            currentUser = nil
            await clearAllCaches()
            followsRepository.clear()
            navigationCoordinator.resetForAccountSwitch()
        } else if wasActive {
            // Logged out the active account, now switched to another
            await savedFeedsRepository.fetchSavedFeeds()
            await followsRepository.fetchFollows()
            navigationCoordinator.resetForAccountSwitch()
        }
    }
    
    /// Logout all accounts
    func logoutAll() async {
        await authRepository.logoutAll()
        currentUser = nil
        await clearAllCaches()
        followsRepository.clear()
        navigationCoordinator.resetForAccountSwitch()
    }
    
    // MARK: - Account Switching
    
    /// Switch to a different account
    /// - Parameter did: The DID of the account to switch to
    /// - Returns: true if switch was successful
    @discardableResult
    func switchAccount(to did: String) async -> Bool {
        guard authRepository.switchAccount(to: did) else {
            return false
        }
        
        // Clear caches and reload data for new account
        await clearAllCaches()
        followsRepository.clear()
        await savedFeedsRepository.fetchSavedFeeds()
        await followsRepository.fetchFollows()
        
        // Reset navigation to default state
        navigationCoordinator.resetForAccountSwitch()
        
        currentUser = mockAuthors[0]  // Mock for now
        
        return true
    }
    
    /// Check if a given DID is the active account
    func isActiveAccount(did: String) -> Bool {
        activeAccountDID == did
    }
}
