//
//  ATProtoClient .swift
//  AlpacaList
//
//  Base HTTP client for AT Protocol API requests
//  Handles URL building, headers, and common request logic
//

import Foundation

/// Base HTTP client for AT Protocol API requests
/// Provides shared functionality for all API clients
class ATProtoClient {
    
    // MARK: - Configuration
    
    /// Default PDS server
    static let defaultServer = "bsky.social"
    
    /// Shared URLSession
    private let session: URLSession
    
    /// JSON encoder for request bodies
    private let encoder = JSONEncoder()
    
    /// JSON decoder for responses
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Request Building
    
    /// Build a URL for an XRPC endpoint
    /// - Parameters:
    ///   - server: The PDS server hostname
    ///   - endpoint: The XRPC method name (e.g., "com.atproto.server.createSession")
    ///   - queryItems: Optional query parameters
    /// - Returns: The constructed URL
    func buildURL(server: String, endpoint: String, queryItems: [URLQueryItem]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = server
        components.path = "/xrpc/\(endpoint)"
        components.queryItems = queryItems?.isEmpty == false ? queryItems : nil
        return components.url
    }
    
    /// Build a URLRequest with common headers
    /// - Parameters:
    ///   - url: The request URL
    ///   - method: HTTP method (GET, POST, etc.)
    ///   - accessToken: Optional bearer token for authenticated requests
    ///   - body: Optional request body (will be JSON encoded)
    /// - Returns: Configured URLRequest
    func buildRequest(url: URL, method: String, accessToken: String? = nil, body: Encodable? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authorization header if token provided
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Encode body if provided
        if let body = body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }
        
        return request
    }
    
    // MARK: - Request Execution
    
    /// Execute a request and decode the response
    /// - Parameters:
    ///   - request: The URLRequest to execute
    ///   - responseType: The expected response type (use `EmptyResponse.self` for no-content responses)
    /// - Returns: Decoded response
    /// - Throws: APIError on failure
    func execute<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(underlying: error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidRequest(message: "Invalid response type")
        }
        
        // Handle error status codes
        if httpResponse.statusCode >= 400 {
            throw mapErrorResponse(data: data, statusCode: httpResponse.statusCode)
        }
        
        // Handle empty responses
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }
        
        // Decode successful response
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(underlying: error)
        }
    }
    
    // MARK: - Error Mapping
    
    /// Map API error response to APIError
    private func mapErrorResponse(data: Data, statusCode: Int) -> APIError {
        // Try to decode error response
        struct ErrorResponse: Decodable {
            let error: String?
            let message: String?
        }
        
        let errorResponse = try? decoder.decode(ErrorResponse.self, from: data)
        let errorCode = errorResponse?.error ?? ""
        let message = errorResponse?.message
        
        switch statusCode {
        case 401:
            if errorCode == "ExpiredToken" {
                return .refreshTokenInvalid
            }
            return .invalidCredentials
            
        case 429:
            // Try to parse retry-after header
            return .rateLimited(retryAfter: nil)
            
        default:
            return .serverError(status: statusCode, message: message ?? errorCode)
        }
    }
}

// MARK: - Empty Response Type

/// Placeholder type for API calls that return no content (e.g., DELETE, some POSTs)
/// Use with `execute(request, responseType: EmptyResponse.self)`
struct EmptyResponse: Decodable {}

// MARK: - Type Erasure Helper

/// Type-erased Encodable wrapper
private struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void
    
    init<T: Encodable>(_ value: T) {
        self.encode = value.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
