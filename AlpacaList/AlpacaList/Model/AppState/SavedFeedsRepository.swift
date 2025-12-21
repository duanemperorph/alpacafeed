//
//  SavedFeedsRepository.swift
//  AlpacaList
//
//  Repository for managing user's saved/pinned feeds
//

import Foundation
import Observation

/// Repository for managing the user's saved and pinned feeds
/// Fetches from preferences API and hydrates with feed generator metadata
@Observable
@MainActor
class SavedFeedsRepository {
    
    // MARK: - Dependencies
    
    private let feedService: FeedService
    
    // MARK: - State
    
    /// The user's saved feeds (hydrated with metadata)
    private(set) var savedFeeds: [SavedFeed] = []
    
    /// Loading state
    private(set) var isLoading = false
    
    /// Error state
    private(set) var error: Error?
    
    /// Whether feeds have been loaded at least once
    private(set) var hasLoaded = false
    
    // MARK: - Raw Preference Data (for putPreferences)
    
    /// Raw saved feed items from preferences (needed for updates)
    private var rawSavedFeedItems: [SavedFeedItemDTO] = []
    
    // MARK: - Initialization
    
    init(feedService: FeedService) {
        self.feedService = feedService
    }
    
    // MARK: - Fetch
    
    /// Fetch the user's saved feeds from preferences and hydrate with metadata
    func fetchSavedFeeds() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        defer { 
            isLoading = false
            hasLoaded = true
        }
        
        do {
            // 1. Get preferences to find saved feed URIs
            let preferencesResponse = try await feedService.getPreferences()
            
            // 2. Extract saved feed items from preferences
            let feedItems = extractSavedFeedItems(from: preferencesResponse.preferences)
            self.rawSavedFeedItems = feedItems
            
            // 3. Get feed URIs (excluding timeline type)
            let feedUris = feedItems
                .filter { $0.type == "feed" }
                .map { $0.value }
            
            guard !feedUris.isEmpty else {
                self.savedFeeds = []
                return
            }
            
            // 4. Hydrate with feed generator metadata
            let generatorsResponse = try await feedService.getFeedGenerators(uris: feedUris)
            
            // 5. Map to SavedFeed domain models, preserving order from preferences
            self.savedFeeds = mapToSavedFeeds(
                feedItems: feedItems,
                generators: generatorsResponse.feeds
            )
            
        } catch {
            self.error = error
        }
    }
    
    /// Refresh saved feeds
    func refresh() async {
        await fetchSavedFeeds()
    }
    
    // MARK: - Mutations
    
    /// Pin a new feed (add to saved feeds)
    func pinFeed(_ feed: SavedFeed) async throws {
        // Add to raw items
        let newItem = SavedFeedItemDTO(
            type: "feed",
            value: feed.uri,
            pinned: true,
            id: UUID().uuidString
        )
        
        var updatedItems = rawSavedFeedItems
        updatedItems.append(newItem)
        
        // Convert to request format and save
        try await savePreferences(items: updatedItems)
        
        // Refresh to get updated list
        await fetchSavedFeeds()
    }
    
    /// Unpin a feed (remove from saved feeds)
    func unpinFeed(uri: String) async throws {
        var updatedItems = rawSavedFeedItems
        updatedItems.removeAll { $0.value == uri }
        
        try await savePreferences(items: updatedItems)
        
        // Update local state immediately
        savedFeeds.removeAll { $0.uri == uri }
        rawSavedFeedItems = updatedItems
    }
    
    // MARK: - Private Helpers
    
    /// Extract saved feed items from preferences array
    private func extractSavedFeedItems(from preferences: [PreferenceItem]) -> [SavedFeedItemDTO] {
        for pref in preferences {
            switch pref {
            case .savedFeedsPrefV2(let v2Pref):
                return v2Pref.items
            case .savedFeedsV2(let legacyPref):
                // Convert legacy format to V2 format
                return convertLegacyToV2(legacyPref)
            case .unknown:
                continue
            }
        }
        return []
    }
    
    /// Convert legacy saved feeds format to V2 format
    private func convertLegacyToV2(_ legacy: SavedFeedsV2DTO) -> [SavedFeedItemDTO] {
        var items: [SavedFeedItemDTO] = []
        
        // Add pinned feeds
        if let pinned = legacy.pinned {
            for (index, uri) in pinned.enumerated() {
                items.append(SavedFeedItemDTO(
                    type: "feed",
                    value: uri,
                    pinned: true,
                    id: "pinned-\(index)"
                ))
            }
        }
        
        // Add saved (non-pinned) feeds
        if let saved = legacy.saved {
            for (index, uri) in saved.enumerated() {
                // Skip if already in pinned
                if legacy.pinned?.contains(uri) == true { continue }
                items.append(SavedFeedItemDTO(
                    type: "feed",
                    value: uri,
                    pinned: false,
                    id: "saved-\(index)"
                ))
            }
        }
        
        return items
    }
    
    /// Map feed items and generators to SavedFeed domain models
    private func mapToSavedFeeds(
        feedItems: [SavedFeedItemDTO],
        generators: [FeedGeneratorDTO]
    ) -> [SavedFeed] {
        // Create lookup by URI
        let generatorsByUri = Dictionary(uniqueKeysWithValues: generators.map { ($0.uri, $0) })
        
        // Map in order, only including feeds we have generator info for
        return feedItems.compactMap { item -> SavedFeed? in
            guard item.type == "feed",
                  let generator = generatorsByUri[item.value] else {
                return nil
            }
            
            return SavedFeed(
                uri: generator.uri,
                name: generator.displayName,
                description: generator.description,
                avatar: generator.avatar,
                creator: generator.creator.handle
            )
        }
    }
    
    /// Save preferences with updated feed items
    private func savePreferences(items: [SavedFeedItemDTO]) async throws {
        let requestItems = items.map { item in
            SavedFeedItemRequest(
                type: item.type,
                value: item.value,
                pinned: item.pinned,
                id: item.id
            )
        }
        
        let savedFeedsPref = SavedFeedsPrefV2Request(items: requestItems)
        try await feedService.putPreferences([.savedFeedsPrefV2(savedFeedsPref)])
    }
}

