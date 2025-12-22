//
//  AuthSessionRepository.swift
//  AlpacaList
//
//  Manages authentication session state and server configuration
//

import Foundation
import Observation

// MARK: - AuthSession

/// Represents an authenticated Bluesky session
struct AuthSession: Codable, Identifiable {
    let did: String           // Decentralized identifier
    let handle: String        // User handle (e.g., "alice.bsky.social")
    let accessJwt: String     // Short-lived access token
    let refreshJwt: String    // Long-lived refresh token
    let server: String        // PDS server (e.g., "bsky.social")
    
    /// Identifiable conformance using DID
    var id: String { did }
}

// MARK: - AuthSessionRepository

/// Manages authentication session state and server configuration
/// - Owns all sessions and the active session
/// - Coordinates login/logout flows
/// - Handles token refresh
/// - Provides server URL for API clients
@Observable
@MainActor
class AuthSessionRepository {
    
    // MARK: - Dependencies
    
    @ObservationIgnored private let credentialStore: CredentialStore
    @ObservationIgnored private let authService: AuthService
    
    // MARK: - Session State
    
    /// All authenticated sessions
    private(set) var allSessions: [AuthSession] = []
    
    /// The DID of the currently active account
    private(set) var activeAccountDID: String?
    
    /// The currently active session
    var currentSession: AuthSession? {
        guard let did = activeAccountDID else { return nil }
        return allSessions.first { $0.did == did }
    }
    
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
    
    /// Number of authenticated accounts
    var accountCount: Int {
        allSessions.count
    }
    
    // MARK: - Server Configuration
    
    /// The PDS server hostname for the current session
    /// e.g., "bsky.social" or "pds.example.com"
    var serverHost: String {
        currentSession?.server ?? ATProtoClient.defaultServer
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
    
    /// Restore all sessions from secure storage on app launch
    /// - Called once at app startup
    func restoreSession() async {
        // Load all sessions
        allSessions = credentialStore.loadAllSessions()
        activeAccountDID = credentialStore.loadActiveAccountDID()
        
        // If we have sessions but no active account, pick the first one
        if activeAccountDID == nil, let firstSession = allSessions.first {
            activeAccountDID = firstSession.did
            credentialStore.saveActiveAccountDID(firstSession.did)
        }
        
        let sessionCount = allSessions.count
        let activeHandle = currentSession?.handle ?? "none"
        print("🔑 [AuthRepo] Loaded \(sessionCount) session(s), active: \(activeHandle)")
    }
    
    // MARK: - Login
    
    /// Authenticate with Bluesky and add account
    /// - Parameters:
    ///   - identifier: Handle or email (e.g., "alice.bsky.social")
    ///   - password: App-specific password
    ///   - server: PDS server hostname (default: "bsky.social")
    ///   - setAsActive: Whether to make this the active account (default: true)
    /// - Returns: The created session on success
    /// - Throws: AuthError on failure
    @discardableResult
    func login(
        identifier: String,
        password: String,
        server: String = ATProtoClient.defaultServer,
        setAsActive: Bool = true
    ) async throws -> AuthSession {
        do {
            let session = try await authService.createSession(
                identifier: identifier,
                password: password,
                server: server
            )
            
            // Check if this account is already logged in
            if let existingIndex = allSessions.firstIndex(where: { $0.did == session.did }) {
                // Update existing session with new tokens
                allSessions[existingIndex] = session
            } else {
                // Add new session
                allSessions.append(session)
            }
            
            // Save to secure storage
            try credentialStore.saveSession(session)
            
            // Set as active if requested
            if setAsActive {
                activeAccountDID = session.did
                credentialStore.saveActiveAccountDID(session.did)
            }
            
            print("🔑 [AuthRepo] Logged in: \(session.handle) (active: \(setAsActive))")
            
            return session
        } catch let error as APIError {
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(underlying: error)
        }
    }
    
    // MARK: - Account Switching
    
    /// Switch to a different account
    /// - Parameter did: The DID of the account to switch to
    /// - Returns: true if switch was successful, false if account not found
    @discardableResult
    func switchAccount(to did: String) -> Bool {
        guard allSessions.contains(where: { $0.did == did }) else {
            print("🔑 [AuthRepo] Switch failed: account \(did) not found")
            return false
        }
        
        activeAccountDID = did
        credentialStore.saveActiveAccountDID(did)
        
        print("🔑 [AuthRepo] Switched to account: \(currentSession?.handle ?? did)")
        return true
    }
    
    // MARK: - Logout
    
    /// Log out a specific account
    /// - Parameter did: The DID of the account to log out
    func logout(did: String) async {
        let handle = allSessions.first { $0.did == did }?.handle ?? did
        
        // Remove from storage and memory
        credentialStore.deleteSession(forDID: did)
        allSessions.removeAll { $0.did == did }
        
        // If we logged out the active account, switch to another or clear
        if activeAccountDID == did {
            if let nextSession = allSessions.first {
                activeAccountDID = nextSession.did
                credentialStore.saveActiveAccountDID(nextSession.did)
                print("🔑 [AuthRepo] Logged out \(handle), switched to \(nextSession.handle)")
            } else {
                activeAccountDID = nil
                credentialStore.deleteActiveAccountDID()
                print("🔑 [AuthRepo] Logged out \(handle), no accounts remaining")
            }
        } else {
            print("🔑 [AuthRepo] Logged out \(handle)")
        }
    }
    
    /// Log out all accounts
    func logoutAll() async {
        credentialStore.deleteAllSessions()
        allSessions = []
        activeAccountDID = nil
        print("🔑 [AuthRepo] Logged out all accounts")
    }
    
    // MARK: - Token Refresh
    
    /// Buffer time before expiry to trigger refresh (60 seconds)
    @ObservationIgnored private let tokenExpiryBuffer: TimeInterval = 60
    
    /// Refresh the access token for a specific session
    /// - Parameter did: The DID of the session to refresh (nil = current session)
    func refreshToken(forDID did: String? = nil) async throws {
        let targetDID = did ?? activeAccountDID
        guard let targetDID,
              let session = allSessions.first(where: { $0.did == targetDID }) else {
            throw AuthError.notAuthenticated
        }
        
        print("🔄 [AuthRepo] Refreshing access token for \(session.handle)...")
        
        do {
            let newSession = try await authService.refreshSession(
                refreshToken: session.refreshJwt,
                server: session.server
            )
            
            // Update in memory
            if let index = allSessions.firstIndex(where: { $0.did == targetDID }) {
                allSessions[index] = newSession
            }
            
            // Save to secure storage
            try credentialStore.saveSession(newSession)
            
            print("🔄 [AuthRepo] Token refreshed for \(newSession.handle)")
        } catch let error as APIError {
            // If refresh fails with invalid token, remove the session
            if case .refreshTokenInvalid = error {
                print("🔄 [AuthRepo] Refresh token invalid for \(session.handle), removing account")
                await logout(did: targetDID)
            }
            throw mapAPIError(error)
        } catch {
            throw AuthError.networkError(underlying: error)
        }
    }
    
    // MARK: - Token Access for API Clients
    
    /// Get a valid access token for the current session, refreshing if expired
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
    private func isTokenExpiredOrExpiring(_ jwt: String) -> Bool {
        guard let expirationDate = getJWTExpirationDate(jwt) else {
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
    private func getJWTExpirationDate(_ jwt: String) -> Date? {
        let parts = jwt.split(separator: ".")
        guard parts.count == 3 else { return nil }
        
        var payload = String(parts[1])
        
        // Convert from base64url to base64
        payload = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        let paddingLength = (4 - payload.count % 4) % 4
        payload += String(repeating: "=", count: paddingLength)
        
        guard let payloadData = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return nil
        }
        
        return Date(timeIntervalSince1970: exp)
    }
    
    // MARK: - Error Mapping
    
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
