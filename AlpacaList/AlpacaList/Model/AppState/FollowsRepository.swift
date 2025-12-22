//
//  FollowsRepository.swift
//  AlpacaList
//
//  Repository for managing the user's followed accounts
//

import Foundation
import Observation

/// Represents a followed account
struct FollowedAccount: Identifiable, Equatable {
    let did: String
    let handle: String
    let displayName: String?
    let description: String?
    let avatar: String?
    let followUri: String?  // URI of the follow record (needed for unfollow)
    
    var id: String { did }
}

/// Repository for managing the user's followed accounts
/// Fetches from graph API and caches in memory
/// Also handles follow/unfollow operations
@Observable
@MainActor
class FollowsRepository {
    
    // MARK: - Dependencies
    
    private let feedService: FeedService
    private let postCache: PostCache
    
    // MARK: - State
    
    /// The user's followed accounts
    private(set) var follows: [FollowedAccount] = []
    
    /// Loading state
    private(set) var isLoading = false
    
    /// Loading more state (pagination)
    private(set) var isLoadingMore = false
    
    /// Error state
    private(set) var error: Error?
    
    /// Whether follows have been loaded at least once
    private(set) var hasLoaded = false
    
    /// Pagination cursor
    private var cursor: String? = nil
    
    /// Whether there are more follows to load
    var hasMore: Bool {
        cursor != nil
    }
    
    // MARK: - Initialization
    
    init(feedService: FeedService, postCache: PostCache) {
        self.feedService = feedService
        self.postCache = postCache
    }
    
    // MARK: - Fetch
    
    /// Fetch the user's followed accounts
    func fetchFollows() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        defer {
            isLoading = false
            hasLoaded = true
        }
        
        do {
            let response = try await feedService.getFollows(limit: 100)
            
            follows = response.follows.map { profile in
                FollowedAccount(
                    did: profile.did,
                    handle: profile.handle,
                    displayName: profile.displayName,
                    description: profile.description,
                    avatar: profile.avatar,
                    followUri: profile.viewer?.following
                )
            }
            cursor = response.cursor
            
        } catch {
            self.error = error
        }
    }
    
    /// Load more followed accounts (pagination)
    func loadMore() async {
        guard !isLoadingMore, let currentCursor = cursor else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            let response = try await feedService.getFollows(cursor: currentCursor, limit: 100)
            
            let newFollows = response.follows.map { profile in
                FollowedAccount(
                    did: profile.did,
                    handle: profile.handle,
                    displayName: profile.displayName,
                    description: profile.description,
                    avatar: profile.avatar,
                    followUri: profile.viewer?.following
                )
            }
            follows.append(contentsOf: newFollows)
            cursor = response.cursor
            
        } catch {
            self.error = error
        }
    }
    
    /// Refresh followed accounts
    func refresh() async {
        cursor = nil
        await fetchFollows()
    }
    
    /// Clear cached follows (e.g., on logout)
    func clear() {
        follows = []
        cursor = nil
        hasLoaded = false
        error = nil
    }
    
    // MARK: - Follow/Unfollow
    
    /// Follow a user
    /// - Parameter author: The author to follow
    /// - Returns: The follow URI on success, nil on failure
    @discardableResult
    func follow(_ author: Author) async -> String? {
        guard !author.isFollowing else {
            // Already following
            return author.followingUri
        }
        
        error = nil
        
        // Optimistic update - set a temporary follow URI in postCache
        let tempFollowUri = "at://temp/app.bsky.graph.follow/pending"
        await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: tempFollowUri)
        
        // Optimistic update - add to follows list
        let tempAccount = FollowedAccount(
            did: author.did,
            handle: author.handle,
            displayName: author.displayName,
            description: nil,
            avatar: author.avatar,
            followUri: tempFollowUri
        )
        follows.insert(tempAccount, at: 0)
        
        do {
            let response = try await feedService.followUser(did: author.did)
            
            // Update postCache with the real follow URI
            await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: response.uri)
            
            // Update follows list with the real follow URI
            if let index = follows.firstIndex(where: { $0.did == author.did }) {
                follows[index] = FollowedAccount(
                    did: author.did,
                    handle: author.handle,
                    displayName: author.displayName,
                    description: nil,
                    avatar: author.avatar,
                    followUri: response.uri
                )
            }
            
            return response.uri
        } catch {
            // Rollback optimistic updates on failure
            await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: nil)
            follows.removeAll { $0.did == author.did }
            self.error = error
            return nil
        }
    }
    
    /// Unfollow a user by Author
    /// - Parameter author: The author to unfollow
    /// - Returns: true if successful
    @discardableResult
    func unfollow(_ author: Author) async -> Bool {
        guard let followUri = author.followingUri else {
            error = FollowsError.missingFollowUri
            return false
        }
        
        error = nil
        
        // Store original state for rollback
        let originalAccount = follows.first { $0.did == author.did }
        
        // Optimistic update - remove from postCache
        await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: nil)
        
        // Optimistic update - remove from follows list
        follows.removeAll { $0.did == author.did }
        
        do {
            try await feedService.unfollowUser(followUri: followUri)
            return true
        } catch {
            // Rollback optimistic updates on failure
            await postCache.updateAuthorFollowState(authorDID: author.did, followingUri: followUri)
            if let account = originalAccount {
                follows.append(account)
            } else {
                // Restore with what we know
                follows.append(FollowedAccount(
                    did: author.did,
                    handle: author.handle,
                    displayName: author.displayName,
                    description: nil,
                    avatar: author.avatar,
                    followUri: followUri
                ))
            }
            self.error = error
            return false
        }
    }
    
    /// Unfollow a user by FollowedAccount (from the Following tab)
    /// - Parameter account: The account to unfollow
    /// - Returns: true if successful
    @discardableResult
    func unfollow(_ account: FollowedAccount) async -> Bool {
        guard let followUri = account.followUri else {
            error = FollowsError.missingFollowUri
            return false
        }
        
        error = nil
        
        // Optimistic update - remove from postCache
        await postCache.updateAuthorFollowState(authorDID: account.did, followingUri: nil)
        
        // Optimistic update - remove from follows list
        follows.removeAll { $0.did == account.did }
        
        do {
            try await feedService.unfollowUser(followUri: followUri)
            return true
        } catch {
            // Rollback optimistic updates on failure
            await postCache.updateAuthorFollowState(authorDID: account.did, followingUri: followUri)
            follows.append(account)
            self.error = error
            return false
        }
    }
    
    enum FollowsError: Error, LocalizedError {
        case missingFollowUri
        
        var errorDescription: String? {
            switch self {
            case .missingFollowUri:
                return "Cannot unfollow: missing follow record URI"
            }
        }
    }
}

