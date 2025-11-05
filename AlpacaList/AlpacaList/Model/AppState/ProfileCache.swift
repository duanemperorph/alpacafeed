//
//  ProfileCache.swift
//  AlpacaList
//
//  Thread-safe actor for caching author/profile data
//

import Foundation

/// Actor for thread-safe profile/author caching
/// Provides global cache for author data to avoid redundant fetches
actor ProfileCache {
    private var profiles: [String: Author] = [:]  // handle or DID -> Author
    
    // MARK: - Read operations
    
    /// Get a profile by handle
    func getProfile(handle: String) -> Author? {
        return profiles[handle]
    }
    
    /// Get a profile by DID
    func getProfileByDID(did: String) -> Author? {
        return profiles[did]
    }
    
    /// Get multiple profiles by handles
    func getProfiles(handles: [String]) -> [Author] {
        return handles.compactMap { profiles[$0] }
    }
    
    /// Get all cached profiles
    func getAllProfiles() -> [Author] {
        return Array(profiles.values)
    }
    
    // MARK: - Write operations
    
    /// Cache a single profile (indexed by both handle and DID)
    func cacheProfile(_ author: Author) {
        profiles[author.handle] = author
        profiles[author.did] = author
    }
    
    /// Cache multiple profiles
    func cacheProfiles(_ authors: [Author]) {
        for author in authors {
            profiles[author.handle] = author
            profiles[author.did] = author
        }
    }
    
    /// Update a profile
    func updateProfile(_ author: Author) {
        profiles[author.handle] = author
        profiles[author.did] = author
    }
    
    /// Clear all cached profiles
    func clear() {
        profiles.removeAll()
    }
    
    /// Remove a specific profile
    func removeProfile(handle: String) {
        if let author = profiles[handle] {
            profiles.removeValue(forKey: handle)
            profiles.removeValue(forKey: author.did)
        }
    }
}

