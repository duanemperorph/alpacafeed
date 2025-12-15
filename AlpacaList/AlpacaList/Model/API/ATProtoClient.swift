//
//  ATProtoClient.swift
//  AlpacaList
//
//  Base client for AT Protocol API requests
//  Handles URL building, headers, and common request logic
//

import Foundation

/// Base client for AT Protocol API requests
/// Provides shared functionality for all API clients
class ATProtoClient {
    
    // MARK: - Configuration
    
    /// Default PDS server
    static let defaultServer = "bsky.social"
    
    /// Base URL for XRPC endpoints
    private func baseURL(server: String) -> String {
        "https://\(server)/xrpc"
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Request Building
    
    /// Build a URL for an XRPC endpoint
    /// - Parameters:
    ///   - endpoint: The XRPC method name (e.g., "com.atproto.server.createSession")
    ///   - server: The PDS server hostname
    ///   - queryItems: Optional query parameters
    /// - Returns: The constructed URL
    func buildURL(endpoint: String, server: String = defaultServer, queryItems: [URLQueryItem]? = nil) -> URL? {
        // TODO: Implementation
        fatalError("Not implemented")
    }
    
    /// Build a URLRequest with common headers
    /// - Parameters:
    ///   - url: The request URL
    ///   - method: HTTP method (GET, POST, etc.)
    ///   - accessToken: Optional bearer token for authenticated requests
    ///   - body: Optional request body (will be JSON encoded)
    /// - Returns: Configured URLRequest
    func buildRequest(url: URL, method: String, accessToken: String? = nil, body: Encodable? = nil) throws -> URLRequest {
        // TODO: Implementation
        fatalError("Not implemented")
    }
    
    // MARK: - Request Execution
    
    /// Execute a request and decode the response
    /// - Parameters:
    ///   - request: The URLRequest to execute
    ///   - responseType: The expected response type
    /// - Returns: Decoded response
    /// - Throws: APIError on failure
    func execute<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        // TODO: Implementation
        // 1. Execute request with URLSession
        // 2. Check HTTP status code
        // 3. Decode response or error
        // 4. Map to APIError if needed
        fatalError("Not implemented")
    }
}

