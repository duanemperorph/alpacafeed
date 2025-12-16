//
//  AuthSessionRepository.swift
//  AlpacaList
//
//  Manages authentication session state and server configuration
//

import Foundation

// MARK: - AuthSession

/// Represents an authenticated Bluesky session
struct AuthSession: Codable {
    let did: String           // Decentralized identifier
    let handle: String        // User handle (e.g., "alice.bsky.social")
    let accessJwt: String     // Short-lived access token
    let refreshJwt: String    // Long-lived refresh token
    let server: String        // PDS server (e.g., "bsky.social")
}

// MARK: - AuthSessionRepository

/// Manages authentication session state and server configuration
/// - Owns the current session and associated server URL
/// - Coordinates login/logout flows
/// - Handles token refresh
/// - Provides server URL for API clients
@MainActor
class AuthSessionRepository {
    
    // MARK: - Dependencies
    
    private let credentialStore: CredentialStore
    private let authService: AuthService
    
    // MARK: - Session State
    
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
    
    // MARK: - Server Configuration
    
    /// The PDS server hostname for the current session
    /// e.g., "bsky.social" or "pds.example.com"
    var serverHost: String {
        currentSession?.server ?? ATProtoClient .defaultServer
    }
    
    /// The base URL for XRPC API calls
    /// e.g., https://bsky.social/xrpc
    var baseURL: URL? {
        URL(string: "https://\(serverHost)/xrpc")
    }
    
    // MARK: - Initialization
    
    init(
        credentialStore: CredentialStore = CredentialStore(),
        authService: AuthService = AuthService()
    ) {
        self.credentialStore = credentialStore
        self.authService = authService
    }
    
    // MARK: - Session Restoration
    
    /// Restore session from secure storage on app launch
    /// - Loads stored session from Keychain via CredentialStore
    /// - Called once at app startup
    func restoreSession() async {
        currentSession = credentialStore.loadSession()
    }
    
    // MARK: - Login
    
    /// Authenticate with Bluesky using identifier and app password
    /// - Parameters:
    ///   - identifier: Handle or email (e.g., "alice.bsky.social")
    ///   - password: App-specific password
    ///   - server: PDS server hostname (default: "bsky.social")
    /// - Returns: The created session on success
    /// - Throws: AuthError on failure
    @discardableResult
    func login(identifier: String, password: String, server: String = ATProtoClient .defaultServer) async throws -> AuthSession {
        do {
            let session = try await authService.createSession(
                identifier: identifier,
                password: password,
                server: server
            )
            
            // Save to secure storage
            try credentialStore.saveSession(session)
            
            // Update state
            currentSession = session
            
            return session
        } catch let error as APIError {
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(underlying: error)
        }
    }
    
    // MARK: - Logout
    
    /// Log out the current session
    /// - Removes session from storage
    /// - Clears currentSession
    func logout() async {
        credentialStore.deleteSession()
        currentSession = nil
    }
    
    // MARK: - Token Refresh
    
    /// Refresh the access token for the current session
    /// - Called when access token expires or API returns 401
    /// - Updates stored session with new tokens
    func refreshToken() async throws {
        guard let session = currentSession else {
            throw AuthError.notAuthenticated
        }
        
        do {
            let newSession = try await authService.refreshSession(
                refreshToken: session.refreshJwt,
                server: session.server
            )
            
            // Save to secure storage
            try credentialStore.saveSession(newSession)
            
            // Update state
            currentSession = newSession
        } catch let error as APIError {
            // If refresh fails, clear the session
            if case .refreshTokenInvalid = error {
                await logout()
            }
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(underlying: error)
        }
    }
    
    /// Refresh token if it's expired or near expiry
    /// - Call this before making authenticated API requests
    /// - No-op if token is still valid
    ///
    /// Note: Currently always refreshes since we don't track token expiry.
    /// TODO: Decode JWT to check expiry and only refresh when needed.
    func refreshTokenIfNeeded() async throws {
        guard currentSession != nil else {
            throw AuthError.notAuthenticated
        }
        
        // TODO: Check if token is near expiry by decoding JWT
        // For now, we don't proactively refresh - let API calls fail and retry
    }
    
    // MARK: - Token Access for API Clients
    
    /// Get a valid access token, refreshing if necessary
    /// - Returns: Valid access JWT
    /// - Throws: If not authenticated or refresh fails
    func getValidAccessToken() async throws -> String {
        guard let session = currentSession else {
            throw AuthError.notAuthenticated
        }
        
        // TODO: Check expiry and refresh if needed
        // try await refreshTokenIfNeeded()
        
        return session.accessJwt
    }
    
    // MARK: - Error Mapping
    
    /// Map API errors to AuthError
    private func mapAPIError(_ error: APIError) -> AuthError {
        switch error {
        case .invalidCredentials:
            return .invalidCredentials
        case .refreshTokenInvalid:
            return .refreshFailed
        case .networkError(let underlying):
            return .networkError(underlying: underlying)
        case .rateLimited:
            return .serverError(message: "Rate limited")
        case .serverError(_, let message):
            return .serverError(message: message ?? "Unknown error")
        case .decodingError:
            return .serverError(message: "Invalid response")
        case .invalidRequest(let message):
            return .serverError(message: message)
        }
    }
    
    // MARK: - Error Types
    
    enum AuthError: Error {
        case notAuthenticated
        case invalidCredentials
        case networkError(underlying: Error)
        case refreshFailed
        case serverError(message: String)
    }
}

// MARK: - Type Alias for Backwards Compatibility

/// Alias for AuthSessionRepository
typealias AuthenticationRepository = AuthSessionRepository
