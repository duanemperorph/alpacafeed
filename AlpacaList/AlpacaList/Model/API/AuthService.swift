//
//  AuthService.swift
//  AlpacaList
//
//  Service for AT Protocol authentication operations
//

import Foundation

/// Service for AT Protocol authentication operations
/// Handles createSession and refreshSession calls
class AuthService {
    
    // MARK: - Dependencies
    
    private let http: ATProtoClient 
    
    // MARK: - Initialization
    
    init(http: ATProtoClient = ATProtoClient ()) {
        self.http = http
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
    func createSession(identifier: String, password: String, server: String = ATProtoClient .defaultServer) async throws -> AuthSession {
        guard let url = http.buildURL(server: server, endpoint: "com.atproto.server.createSession") else {
            throw APIError.invalidRequest(message: "Failed to build URL")
        }
        
        let body = CreateSessionRequest(identifier: identifier, password: password)
        let request = try http.buildRequest(url: url, method: "POST", body: body)
        
        let response = try await http.execute(request, responseType: SessionResponse.self)
        
        return AuthSession(
            did: response.did,
            handle: response.handle,
            accessJwt: response.accessJwt,
            refreshJwt: response.refreshJwt,
            server: server
        )
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
        guard let url = http.buildURL(server: server, endpoint: "com.atproto.server.refreshSession") else {
            throw APIError.invalidRequest(message: "Failed to build URL")
        }
        
        let request = try http.buildRequest(url: url, method: "POST", accessToken: refreshToken)
        
        let response = try await http.execute(request, responseType: SessionResponse.self)
        
        return AuthSession(
            did: response.did,
            handle: response.handle,
            accessJwt: response.accessJwt,
            refreshJwt: response.refreshJwt,
            server: server
        )
    }
}

// MARK: - Request/Response Types

/// Request body for createSession
private struct CreateSessionRequest: Encodable {
    let identifier: String
    let password: String
}

/// Response from createSession and refreshSession
private struct SessionResponse: Decodable {
    let did: String
    let handle: String
    let accessJwt: String
    let refreshJwt: String
    // Optional fields we don't need
    // let email: String?
    // let emailConfirmed: Bool?
}
