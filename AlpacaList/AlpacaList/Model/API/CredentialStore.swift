//
//  CredentialStore.swift
//  AlpacaList
//
//  Secure storage for authentication credentials using Keychain
//

import Foundation
import Security

/// Secure storage for authentication credentials
/// Wraps Keychain access for storing/retrieving AuthSession
class CredentialStore {
    
    // MARK: - Keychain Configuration
    
    private let service = "com.alpacalist.auth"
    private let account = "authSession"
    
    /// JSON encoder/decoder
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Session Storage
    
    /// Save session to Keychain
    /// - Parameter session: The session to store
    /// - Throws: CredentialError on failure
    func saveSession(_ session: AuthSession) throws {
        let data = try encoder.encode(session)
        
        // Delete existing item first
        deleteSession()
        
        // Create query for adding new item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw CredentialError.saveFailed(status: status)
        }
    }
    
    /// Load session from Keychain
    /// - Returns: The stored session, or nil if not found
    func loadSession() -> AuthSession? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return try? decoder.decode(AuthSession.self, from: data)
    }
    
    /// Delete session from Keychain
    func deleteSession() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    /// Check if a session exists in Keychain
    var hasStoredSession: Bool {
        loadSession() != nil
    }
    
    // MARK: - Error Types
    
    enum CredentialError: Error {
        case encodingFailed
        case saveFailed(status: OSStatus)
        case loadFailed(status: OSStatus)
        case deleteFailed(status: OSStatus)
    }
}
