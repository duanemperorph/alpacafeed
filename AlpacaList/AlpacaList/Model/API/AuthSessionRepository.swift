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
        print("🔑 [AuthRepo] Loaded session: \(currentSession != nil ? "found (\(currentSession!.handle))" : "nil")")
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
    
    /// Buffer time before expiry to trigger refresh (60 seconds)
    private let tokenExpiryBuffer: TimeInterval = 60
    
    /// Refresh the access token for the current session
    /// - Called when access token expires or is near expiry
    /// - Updates stored session with new tokens
    func refreshToken() async throws {
        guard let session = currentSession else {
            throw AuthError.notAuthenticated
        }
        
        print("🔄 [AuthRepo] Refreshing access token...")
        
        do {
            let newSession = try await authService.refreshSession(
                refreshToken: session.refreshJwt,
                server: session.server
            )
            
            // Save to secure storage
            try credentialStore.saveSession(newSession)
            
            // Update state
            currentSession = newSession
            
            print("🔄 [AuthRepo] Token refreshed successfully")
        } catch let error as APIError {
            // If refresh fails, clear the session
            if case .refreshTokenInvalid = error {
                print("🔄 [AuthRepo] Refresh token invalid, logging out")
                await logout()
            }
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(underlying: error)
        }
    }
    
    // MARK: - Token Access for API Clients
    
    /// Get a valid access token, refreshing if expired or near expiry
    /// - Returns: Valid access JWT
    /// - Throws: If not authenticated or refresh fails
    func getValidAccessToken() async throws -> String {
        guard let session = currentSession else {
            throw AuthError.notAuthenticated
        }
        
        // Check if token is expired or about to expire
        if isTokenExpiredOrExpiring(session.accessJwt) {
            print("🔄 [AuthRepo] Access token expired or expiring, refreshing...")
            try await refreshToken()
            
            // Return the new token after refresh
            guard let refreshedSession = currentSession else {
                throw AuthError.notAuthenticated
            }
            return refreshedSession.accessJwt
        }
        
        return session.accessJwt
    }
    
    // MARK: - JWT Expiration Check
    
    /// Check if a JWT is expired or will expire within the buffer period
    /// - Parameter jwt: The JWT string to check
    /// - Returns: true if token is expired or expiring soon
    private func isTokenExpiredOrExpiring(_ jwt: String) -> Bool {
        guard let expirationDate = getJWTExpirationDate(jwt) else {
            // If we can't decode the JWT, assume it's expired to be safe
            print("🔄 [AuthRepo] Could not decode JWT expiration, assuming expired")
            return true
        }
        
        let now = Date()
        let expiryWithBuffer = expirationDate.addingTimeInterval(-tokenExpiryBuffer)
        
        let isExpiring = now >= expiryWithBuffer
        if isExpiring {
            print("🔄 [AuthRepo] Token expires at \(expirationDate), now is \(now)")
        }
        
        return isExpiring
    }
    
    /// Decode a JWT and extract the expiration date
    /// - Parameter jwt: The JWT string (header.payload.signature)
    /// - Returns: The expiration date, or nil if decoding fails
    private func getJWTExpirationDate(_ jwt: String) -> Date? {
        let parts = jwt.split(separator: ".")
        guard parts.count == 3 else { return nil }
        
        // Get the payload (second part)
        var payload = String(parts[1])
        
        // Convert from base64url to base64
        payload = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        let paddingLength = (4 - payload.count % 4) % 4
        payload += String(repeating: "=", count: paddingLength)
        
        // Decode base64
        guard let payloadData = Data(base64Encoded: payload) else { return nil }
        
        // Parse JSON to extract exp claim
        guard let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return nil
        }
        
        return Date(timeIntervalSince1970: exp)
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
