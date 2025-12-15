//
//  AuthenticationRepository.swift
//  AlpacaList
//
//  Coordinates authentication state and token management for a single account
//

import Foundation

// MARK: - AuthSession (TODO: Move to Model/Data/AuthSession.swift)

/// Represents an authenticated Bluesky session
struct AuthSession: Codable {
    let did: String           // Decentralized identifier
    let handle: String        // User handle (e.g., "alice.bsky.social")
    let accessJwt: String     // Short-lived access token
    let refreshJwt: String    // Long-lived refresh token
    let server: String        // PDS server (e.g., "bsky.social")
    
    // TODO: Add accessJwtExpiry: Date? for proactive refresh
    // TODO: Add method to check if token needs refresh
}

// MARK: - AuthenticationRepository

/// Manages authentication state and token lifecycle for a single account
/// - Coordinates login/logout flows
/// - Handles token refresh
/// - Owned by AppState as a sub-component
/// - Delegates secure storage to CredentialStore
@MainActor
class AuthenticationRepository {
    
    // MARK: - Dependencies
    
    // TODO: Add CredentialStore dependency for Keychain access
    // private let credentialStore: CredentialStore
    
    // TODO: Add API client for auth endpoints
    // private let authClient: ATProtoAuthClient
    
    // MARK: - Observable State
    
    /// The current session (nil if not authenticated)
    private(set) var currentSession: AuthSession?
    
    // MARK: - Computed Properties
    
    /// Whether there is an active authenticated session
    var isAuthenticated: Bool {
        currentSession != nil
    }
    
    /// The DID of the current user
    var currentDID: String? {
        currentSession?.did
    }
    
    /// The handle of the current user
    var currentHandle: String? {
        currentSession?.handle
    }
    
    // MARK: - Initialization
    
    init() {
        // TODO: Inject CredentialStore and API client
        // self.credentialStore = credentialStore
        // self.authClient = authClient
    }
    
    /// Restore session from secure storage on app launch
    /// - Loads stored session from Keychain via CredentialStore
    /// - Called once at app startup
    func restoreSession() async {
        // TODO: Implementation
        // 1. Call credentialStore.getSession()
        // 2. If exists, set as currentSession
        // 3. Optionally validate token is still valid
    }
    
    // MARK: - Login
    
    /// Authenticate with Bluesky using identifier and app password
    /// - Parameters:
    ///   - identifier: Handle or email (e.g., "alice.bsky.social")
    ///   - password: App-specific password
    ///   - server: PDS server hostname (default: "bsky.social")
    /// - Returns: The created session on success
    /// - Throws: AuthError on failure
    ///
    /// API: POST https://{server}/xrpc/com.atproto.server.createSession
    /// Body: { "identifier": "...", "password": "..." }
    /// Response: { "did", "handle", "accessJwt", "refreshJwt", ... }
    @discardableResult
    func login(identifier: String, password: String, server: String = "bsky.social") async throws -> AuthSession {
        // TODO: Implementation
        // 1. Set isLoading = true
        // 2. Call com.atproto.server.createSession
        // 3. Create AuthSession from response
        // 4. Store in CredentialStore
        // 5. Set as currentSession
        // 6. Set isLoading = false
        // 7. Return session
        
        fatalError("Not implemented")
    }
    
    // MARK: - Logout
    
    /// Log out the current session
    /// - Removes session from storage
    /// - Clears currentSession
    /// - Does NOT call server endpoint (tokens just expire)
    func logout() async {
        // TODO: Implementation
        // 1. Remove from CredentialStore
        // 2. Set currentSession = nil
        // 3. Notify observers (automatic via @Observable)
    }
    
    // MARK: - Token Refresh
    
    /// Refresh the access token for the current session
    /// - Called when access token expires or API returns 401
    /// - Updates stored session with new tokens
    ///
    /// API: POST https://{server}/xrpc/com.atproto.server.refreshSession
    /// Header: Authorization: Bearer {refreshJwt}
    /// Response: { "accessJwt", "refreshJwt", ... }
    func refreshToken() async throws {
        // TODO: Implementation
        // 1. Guard currentSession exists
        // 2. Call com.atproto.server.refreshSession with refreshJwt
        // 3. Update AuthSession with new tokens
        // 4. Update in CredentialStore
        // 5. Update currentSession
    }
    
    /// Refresh token if it's expired or near expiry
    /// - Call this before making authenticated API requests
    /// - No-op if token is still valid
    func refreshTokenIfNeeded() async throws {
        // TODO: Implementation
        // 1. Check if currentSession?.accessJwtExpiry is near/past
        // 2. If so, call refreshToken()
        // 3. Otherwise, return immediately
    }
    
    // MARK: - Token Access for API Clients
    
    /// Get a valid access token, refreshing if necessary
    /// - Returns: Valid access JWT
    /// - Throws: If not authenticated or refresh fails
    ///
    /// Use this in API clients before making authenticated requests
    func getValidAccessToken() async throws -> String {
        // TODO: Implementation
        // 1. Guard currentSession exists, throw .notAuthenticated
        // 2. Call refreshTokenIfNeeded()
        // 3. Return currentSession.accessJwt
        
        fatalError("Not implemented")
    }
}
