//
//  APIError.swift
//  AlpacaList
//
//  Shared error types for AT Protocol API clients
//

import Foundation

/// Errors that can occur during AT Protocol API calls
enum APIError: Error {
    /// Invalid credentials (wrong handle/password)
    case invalidCredentials
    
    /// Network error (no internet, timeout, DNS failure)
    case networkError(underlying: Error)
    
    /// Refresh token was rejected (expired or revoked)
    case refreshTokenInvalid
    
    /// Rate limited by server
    case rateLimited(retryAfter: TimeInterval?)
    
    /// Server returned an error response
    case serverError(status: Int, message: String?)
    
    /// Response could not be decoded
    case decodingError(underlying: Error)
    
    /// Request was invalid
    case invalidRequest(message: String)
}

