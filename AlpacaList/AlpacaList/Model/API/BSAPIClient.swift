//
//  BSAPIClient.swift
//  AlpacaList
//
//  Handles authenticated API calls with automatic token management
//

import Foundation

/// Service for making authenticated AT Protocol / Bluesky API calls
/// - Obtains access token from session repository
/// - Refreshes token if needed before calls
/// - Retries on 401 with fresh token
/// - Provides server URL from current session
class BSAPIClient {
    
    // MARK: - Dependencies
    
    /// Unowned reference to avoid retain cycles (session repo outlives this client)
    private unowned let sessionRepository: AuthSessionRepository
    private let http: ATProtoClient 
    
    // MARK: - Configuration
    
    /// Maximum retry attempts for token refresh
    private let maxRetryAttempts = 1
    
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
    
    /// Execute a request with authentication and retry logic
    @MainActor
    private func executeWithAuth<Body: Encodable, T: Decodable>(
        endpoint: String,
        method: String,
        queryItems: [URLQueryItem]?,
        body: Body?,
        responseType: T.Type,
        retryCount: Int = 0
    ) async throws -> T {
        // Get valid access token
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
        
        do {
            return try await http.execute(request, responseType: responseType)
        } catch APIError.invalidCredentials where retryCount < maxRetryAttempts {
            // Token expired, try to refresh and retry
            try await sessionRepository.refreshToken()
            return try await executeWithAuth(
                endpoint: endpoint,
                method: method,
                queryItems: queryItems,
                body: body,
                responseType: responseType,
                retryCount: retryCount + 1
            )
        }
    }
    
    /// Execute a request with authentication that returns no content
    @MainActor
    private func executeWithAuthNoContent<Body: Encodable>(
        endpoint: String,
        method: String,
        body: Body?,
        retryCount: Int = 0
    ) async throws {
        // Get valid access token
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
        
        do {
            _ = try await http.execute(request, responseType: EmptyResponse.self)
        } catch APIError.invalidCredentials where retryCount < maxRetryAttempts {
            // Token expired, try to refresh and retry
            try await sessionRepository.refreshToken()
            try await executeWithAuthNoContent(
                endpoint: endpoint,
                method: method,
                body: body,
                retryCount: retryCount + 1
            )
        }
    }
}

// MARK: - Helper Types

/// Empty body for GET requests
private struct EmptyBody: Encodable {}

