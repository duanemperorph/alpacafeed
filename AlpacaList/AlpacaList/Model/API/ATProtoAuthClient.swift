//
//  ATProtoAuthClient.swift
//  AlpacaList
//
//  API client for AT Protocol authentication endpoints
//

import Foundation

/// API client for AT Protocol authentication endpoints
/// Handles createSession and refreshSession calls
class ATProtoAuthClient {
    
    // MARK: - Dependencies
    
    private let client: ATProtoClient
    
    // MARK: - Initialization
    
    init(client: ATProtoClient = ATProtoClient()) {
        self.client = client
    }
    
    // MARK: - Create Session (Login)
    
    /// Create a new session (login)
    /// - Parameters:
    ///   - identifier: Handle or email (e.g., "alice.bsky.social")
    ///   - password: App-specific password
    ///   - server: PDS server hostname (default: "bsky.social")
    /// - Returns: The created session
    /// - Throws: APIError on failure
    ///
    /// API: POST /xrpc/com.atproto.server.createSession
    /// Body: { "identifier": "...", "password": "..." }
    func createSession(identifier: String, password: String, server: String = ATProtoClient.defaultServer) async throws -> AuthSession {
        // TODO: Implementation
        // 1. Build URL for com.atproto.server.createSession
        // 2. Build POST request with JSON body
        // 3. Execute and decode response
        // 4. Map errors (401 -> invalidCredentials, etc.)
        fatalError("Not implemented")
    }
    
    // MARK: - Refresh Session
    
    /// Refresh an existing session
    /// - Parameters:
    ///   - refreshToken: The refresh JWT from the current session
    ///   - server: PDS server hostname
    /// - Returns: Updated session with new tokens
    /// - Throws: APIError on failure
    ///
    /// API: POST /xrpc/com.atproto.server.refreshSession
    /// Header: Authorization: Bearer {refreshJwt}
    func refreshSession(refreshToken: String, server: String) async throws -> AuthSession {
        // TODO: Implementation
        // 1. Build URL for com.atproto.server.refreshSession
        // 2. Build POST request with Bearer token header
        // 3. Execute and decode response
        // 4. Map errors (401 -> refreshTokenInvalid, etc.)
        fatalError("Not implemented")
    }
}

