//
//  BSAPIClient.swift
//  AlpacaList
//
//  Handles authenticated API calls with automatic token management
//

import Foundation

/// Service for making authenticated AT Protocol / Bluesky API calls
/// - Obtains valid access token from session repository (refreshes proactively if expired)
/// - Provides server URL from current session
class BSAPIClient {
    
    // MARK: - Dependencies
    
    /// Unowned reference to avoid retain cycles (session repo outlives this client)
    private unowned let sessionRepository: AuthSessionRepository
    private let http: ATProtoClient 
    
    // MARK: - Initialization
    
    init(
        sessionRepository: AuthSessionRepository,
        http: ATProtoClient = ATProtoClient ()
    ) {
        self.sessionRepository = sessionRepository
        self.http = http
    }
    
    // MARK: - Session Info
    
    /// The current server host from the session
    @MainActor
    var serverHost: String {
        sessionRepository.serverHost
    }
    
    /// The base URL for API calls
    @MainActor
    var baseURL: URL? {
        sessionRepository.baseURL
    }
    
    /// The current user's DID
    @MainActor
    var currentDID: String? {
        sessionRepository.currentDID
    }
    
    /// The current user's handle
    @MainActor
    var currentHandle: String? {
        sessionRepository.currentHandle
    }
    
    // MARK: - Authenticated Requests
    
    /// Execute an authenticated GET request
    /// - Parameters:
    ///   - endpoint: The XRPC endpoint (e.g., "app.bsky.feed.getTimeline")
    ///   - queryItems: Optional query parameters
    ///   - responseType: The expected response type
    /// - Returns: Decoded response
    /// - Throws: APIError or AuthSessionRepository.AuthError
    @MainActor
    func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await executeWithAuth(
            endpoint: endpoint,
            method: "GET",
            queryItems: queryItems,
            body: nil as EmptyBody?,
            responseType: responseType
        )
    }
    
    /// Execute an authenticated POST request
    /// - Parameters:
    ///   - endpoint: The XRPC endpoint (e.g., "com.atproto.repo.createRecord")
    ///   - body: The request body (will be JSON encoded)
    ///   - responseType: The expected response type
    /// - Returns: Decoded response
    /// - Throws: APIError or AuthSessionRepository.AuthError
    @MainActor
    func post<Body: Encodable, T: Decodable>(
        endpoint: String,
        body: Body,
        responseType: T.Type
    ) async throws -> T {
        try await executeWithAuth(
            endpoint: endpoint,
            method: "POST",
            queryItems: nil,
            body: body,
            responseType: responseType
        )
    }
    
    /// Execute an authenticated POST request with no response body
    /// - Parameters:
    ///   - endpoint: The XRPC endpoint
    ///   - body: The request body
    /// - Throws: APIError or AuthSessionRepository.AuthError
    @MainActor
    func post<Body: Encodable>(
        endpoint: String,
        body: Body
    ) async throws {
        try await executeWithAuthNoContent(
            endpoint: endpoint,
            method: "POST",
            body: body
        )
    }
    
    // MARK: - Internal Execution
    
    /// Execute a request with authentication
    /// Token refresh is handled proactively by getValidAccessToken()
    @MainActor
    private func executeWithAuth<Body: Encodable, T: Decodable>(
        endpoint: String,
        method: String,
        queryItems: [URLQueryItem]?,
        body: Body?,
        responseType: T.Type
    ) async throws -> T {
        // Get valid access token (automatically refreshes if expired/expiring)
        let accessToken = try await sessionRepository.getValidAccessToken()
        
        // Build URL
        guard let url = http.buildURL(
            server: serverHost,
            endpoint: endpoint,
            queryItems: queryItems
        ) else {
            throw APIError.invalidRequest(message: "Failed to build URL for \(endpoint)")
        }
        
        // Build request
        let request = try http.buildRequest(
            url: url,
            method: method,
            accessToken: accessToken,
            body: body
        )
        
        return try await http.execute(request, responseType: responseType)
    }
    
    /// Execute a request with authentication that returns no content
    /// Token refresh is handled proactively by getValidAccessToken()
    @MainActor
    private func executeWithAuthNoContent<Body: Encodable>(
        endpoint: String,
        method: String,
        body: Body?
    ) async throws {
        // Get valid access token (automatically refreshes if expired/expiring)
        let accessToken = try await sessionRepository.getValidAccessToken()
        
        // Build URL
        guard let url = http.buildURL(
            server: serverHost,
            endpoint: endpoint
        ) else {
            throw APIError.invalidRequest(message: "Failed to build URL for \(endpoint)")
        }
        
        // Build request
        let request = try http.buildRequest(
            url: url,
            method: method,
            accessToken: accessToken,
            body: body
        )
        
        _ = try await http.execute(request, responseType: EmptyResponse.self)
    }
}

// MARK: - Helper Types

/// Empty body for GET requests
private struct EmptyBody: Encodable {}

