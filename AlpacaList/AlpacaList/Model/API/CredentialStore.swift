//
//  CredentialStore.swift
//  AlpacaList
//
//  Secure storage for authentication credentials using Keychain
//

import Foundation
import Security

/// Secure storage for authentication credentials
/// Wraps Keychain access for storing/retrieving multiple AuthSessions
class CredentialStore {
    
    // MARK: - Keychain Configuration
    
    private let service = "com.alpacalist.auth"
    
    /// Keychain account keys
    private enum KeychainKey {
        static let sessions = "authSessions"       // Stores array of all sessions
        static let activeAccountDID = "activeAccountDID"  // Stores the active account DID
    }
    
    /// JSON encoder/decoder
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Multi-Account Session Storage
    
    /// Save all sessions to Keychain
    /// - Parameter sessions: Array of sessions to store
    /// - Throws: CredentialError on failure
    func saveSessions(_ sessions: [AuthSession]) throws {
        let data = try encoder.encode(sessions)
        try saveData(data, forKey: KeychainKey.sessions)
    }
    
    /// Load all sessions from Keychain
    /// - Returns: Array of stored sessions, or empty array if none found
    func loadAllSessions() -> [AuthSession] {
        guard let data = loadData(forKey: KeychainKey.sessions) else {
            return []
        }
        return (try? decoder.decode([AuthSession].self, from: data)) ?? []
    }
    
    /// Add or update a session in the stored sessions
    /// - Parameter session: The session to add or update (matched by DID)
    /// - Throws: CredentialError on failure
    func saveSession(_ session: AuthSession) throws {
        var sessions = loadAllSessions()
        
        // Update existing or append new
        if let index = sessions.firstIndex(where: { $0.did == session.did }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        
        try saveSessions(sessions)
    }
    
    /// Delete a specific session by DID
    /// - Parameter did: The DID of the session to delete
    func deleteSession(forDID did: String) {
        var sessions = loadAllSessions()
        sessions.removeAll { $0.did == did }
        try? saveSessions(sessions)
        
        // Clear active account if it was the deleted one
        if loadActiveAccountDID() == did {
            deleteActiveAccountDID()
        }
    }
    
    /// Delete all sessions
    func deleteAllSessions() {
        deleteData(forKey: KeychainKey.sessions)
        deleteActiveAccountDID()
    }
    
    /// Get a specific session by DID
    /// - Parameter did: The DID to look up
    /// - Returns: The session if found, nil otherwise
    func getSession(forDID did: String) -> AuthSession? {
        return loadAllSessions().first { $0.did == did }
    }
    
    // MARK: - Active Account Management
    
    /// Save the active account DID
    /// - Parameter did: The DID of the active account
    func saveActiveAccountDID(_ did: String) {
        guard let data = did.data(using: .utf8) else { return }
        try? saveData(data, forKey: KeychainKey.activeAccountDID)
    }
    
    /// Load the active account DID
    /// - Returns: The active account DID, or nil if not set
    func loadActiveAccountDID() -> String? {
        guard let data = loadData(forKey: KeychainKey.activeAccountDID) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Delete the active account DID
    func deleteActiveAccountDID() {
        deleteData(forKey: KeychainKey.activeAccountDID)
    }
    
    // MARK: - Convenience Properties
    
    /// Check if any sessions exist in Keychain
    var hasStoredSessions: Bool {
        !loadAllSessions().isEmpty
    }
    
    /// Get the count of stored sessions
    var sessionCount: Int {
        loadAllSessions().count
    }
    
    // MARK: - Private Keychain Helpers
    
    /// Save data to Keychain for a given key
    private func saveData(_ data: Data, forKey key: String) throws {
        // Delete existing item first
        deleteData(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw CredentialError.saveFailed(status: status)
        }
    }
    
    /// Load data from Keychain for a given key
    private func loadData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        return result as? Data
    }
    
    /// Delete data from Keychain for a given key
    private func deleteData(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Error Types
    
    enum CredentialError: Error {
        case encodingFailed
        case saveFailed(status: OSStatus)
        case loadFailed(status: OSStatus)
        case deleteFailed(status: OSStatus)
    }
}
