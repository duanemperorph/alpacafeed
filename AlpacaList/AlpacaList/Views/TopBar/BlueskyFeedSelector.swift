//
//  BlueskyFeedSelector.swift
//  AlpacaList
//
//  Feed type selector for Bluesky mode
//

import SwiftUI

// MARK: - Feed Selector Pill Style

struct FeedSelectorPillStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30)
            .padding(.horizontal, 15)
            .foregroundColor(.white)
            .font(.system(size: 16))
            .fontWeight(.semibold)
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}

extension View {
    func feedSelectorPillStyle() -> some View {
        modifier(FeedSelectorPillStyle())
    }
}

// MARK: - Saved Feed Model

/// Represents a custom feed generator (algorithm feed)
struct SavedFeed: Hashable, Identifiable {
    let uri: String
    let name: String
    let description: String?
    let avatar: String?
    let creator: String?
    
    var id: String { uri }
    
    init(uri: String, name: String, description: String? = nil, avatar: String? = nil, creator: String? = nil) {
        self.uri = uri
        self.name = name
        self.description = description
        self.avatar = avatar
        self.creator = creator
    }
}

// MARK: - Feed Type

/// Feed type: either the home timeline (Following) or a custom feed
enum FeedType: Hashable {
    case following
    case custom(SavedFeed)
    
    /// Display name for the feed
    var displayName: String {
        switch self {
        case .following:
            return "Following"
        case .custom(let feed):
            return feed.name
        }
    }
}

// MARK: - Mock Data

extension SavedFeed {
    static let mockSavedFeeds: [SavedFeed] = [
        SavedFeed(
            uri: "at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot",
            name: "Discover",
            description: "Discover new and interesting content",
            creator: "Bluesky"
        ),
        SavedFeed(
            uri: "at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/hot-classic",
            name: "What's Hot",
            description: "The hottest posts right now",
            creator: "Bluesky"
        ),
        SavedFeed(
            uri: "at://did:plc:vpkhqolt662uhesyj6nxm7ys/app.bsky.feed.generator/infreq",
            name: "Quiet Posters",
            description: "Posts from people who don't post often",
            creator: "@why.bsky.team"
        ),
    ]
    
    static let mockSuggestedFeeds: [SavedFeed] = [
        SavedFeed(
            uri: "at://did:plc:xxx/app.bsky.feed.generator/science",
            name: "Science",
            description: "Scientific discoveries and discussions",
            creator: "@science.bsky.social"
        ),
        SavedFeed(
            uri: "at://did:plc:xxx/app.bsky.feed.generator/art",
            name: "Art",
            description: "Creative works and artistic expression",
            creator: "@art.bsky.social"
        ),
        SavedFeed(
            uri: "at://did:plc:xxx/app.bsky.feed.generator/news",
            name: "News",
            description: "Breaking news and current events",
            creator: "@news.bsky.social"
        ),
        SavedFeed(
            uri: "at://did:plc:xxx/app.bsky.feed.generator/tech",
            name: "Tech",
            description: "Technology news and discussions",
            creator: "@tech.bsky.social"
        ),
    ]
}

// MARK: - Feed Selector Button

/// Button that shows current feed and opens the feed selector sheet
struct FeedSelectorButton: View {
    let currentFeed: FeedType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(currentFeed.displayName)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .feedSelectorPillStyle()
    }
}

