//
//  NavigationCoordinator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/6/23.
//

import SwiftUI

// MARK: - Navigation Destination

/// Navigation destinations for the app
enum NavigationDestination {
    // Legacy (keep for backwards compatibility during migration)
    case postDetails(postItem: FeedItem)
    
    // Bluesky navigation
    case timeline(type: TimelineType)        // Home, profile, custom feed
    case thread(uri: String)                 // Post thread
    case profile(handle: String)             // User profile
    case compose(replyTo: Post?)             // New post/reply
    case quotePost(post: Post)               // Quote post composer
    
    // Settings
    case instanceSettings
    case userSettings
    case blueskySettings
    
    // Timeline types
    enum TimelineType: Hashable {
        case home                            // User's home feed
        case authorFeed(handle: String)      // Specific author's posts
        case customFeed(uri: String)         // Algorithm feed (e.g., discover, trending)
        case likes(handle: String)           // User's liked posts
    }
}

// MARK: - Hashable Conformance

extension NavigationDestination: Hashable {
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        // Legacy
        case (.postDetails(let item1), .postDetails(let item2)):
            return item1.id == item2.id
            
        // Bluesky
        case (.timeline(let type1), .timeline(let type2)):
            return type1 == type2
        case (.thread(let uri1), .thread(let uri2)):
            return uri1 == uri2
        case (.profile(let handle1), .profile(let handle2)):
            return handle1 == handle2
        case (.compose(let post1), .compose(let post2)):
            return post1?.id == post2?.id
        case (.quotePost(let post1), .quotePost(let post2)):
            return post1.id == post2.id
            
        // Settings
        case (.instanceSettings, .instanceSettings):
            return true
        case (.userSettings, .userSettings):
            return true
        case (.blueskySettings, .blueskySettings):
            return true
            
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        // Legacy
        case .postDetails(let item):
            hasher.combine("postDetails")
            hasher.combine(item.id)
            
        // Bluesky
        case .timeline(let type):
            hasher.combine("timeline")
            hasher.combine(type)
        case .thread(let uri):
            hasher.combine("thread")
            hasher.combine(uri)
        case .profile(let handle):
            hasher.combine("profile")
            hasher.combine(handle)
        case .compose(let post):
            hasher.combine("compose")
            hasher.combine(post?.id)
        case .quotePost(let post):
            hasher.combine("quotePost")
            hasher.combine(post.id)
            
        // Settings
        case .instanceSettings:
            hasher.combine("instanceSettings")
        case .userSettings:
            hasher.combine("userSettings")
        case .blueskySettings:
            hasher.combine("blueskySettings")
        }
    }
}

// MARK: - Navigation Coordinator

class NavigationCoordinator: ObservableObject {
    @Published var navigationStack: [NavigationDestination]
    
    init() {
        navigationStack = []
    }
    
    init(initialStack: [NavigationDestination]) {
        self.navigationStack = initialStack
    }
    
    var canPop: Bool {
        return navigationStack.count > 0
    }
    
    func push(_ destination: NavigationDestination) {
        navigationStack.append(destination)
    }
    
    func pop() {
        navigationStack.removeLast()
    }
    
    func popToRoot() {
        navigationStack.removeAll()
    }

    @ViewBuilder func viewForDestination(destination: NavigationDestination) -> some View {
        switch destination {
        // Legacy navigation (keep for backwards compatibility)
        case .postDetails(let postItem):
            let model = CommentsListViewModel(post: postItem)
            CommentsFeedView(model: model)
            
        // Bluesky navigation
        case .timeline(let type):
            let viewModel = TimelineViewModel(timelineType: timelineTypeFromDestination(type))
            TimelineView(viewModel: viewModel)
                .navigationTitle(titleForTimelineType(type))
            
        case .thread(let uri):
            let viewModel = ThreadViewModel(postUri: uri)
            ThreadView(viewModel: viewModel)
                .navigationTitle("Thread")
                .navigationBarTitleDisplayMode(.inline)
            
        case .profile(let handle):
            // TODO: Create ProfileView
            let viewModel = TimelineViewModel(timelineType: .authorFeed(handle: handle))
            TimelineView(viewModel: viewModel)
                .navigationTitle("@\(handle)")
            
        case .compose(let replyTo):
            // TODO: Create ComposeView
            Text("Compose new post")
                .navigationTitle(replyTo == nil ? "New Post" : "Reply")
            
        case .quotePost(let post):
            // TODO: Create QuotePostView
            Text("Quote post: \(post.text)")
                .navigationTitle("Quote Post")
            
        // Settings
        case .instanceSettings:
            InstanceSettings()
            
        case .userSettings:
            UserSettings()
            
        case .blueskySettings:
            BlueskySettings()
        }
    }
    
    // MARK: - Helper Methods
    
    private func timelineTypeFromDestination(_ type: NavigationDestination.TimelineType) -> TimelineViewModel.TimelineType {
        switch type {
        case .home:
            return .home
        case .authorFeed(let handle):
            return .authorFeed(handle: handle)
        case .customFeed(let uri):
            return .customFeed(uri: uri)
        case .likes:
            return .home // TODO: Add likes timeline type
        }
    }
    
    private func titleForTimelineType(_ type: NavigationDestination.TimelineType) -> String {
        switch type {
        case .home:
            return "Home"
        case .authorFeed(let handle):
            return "@\(handle)"
        case .customFeed:
            return "Feed"
        case .likes(let handle):
            return "@\(handle)'s Likes"
        }
    }
}
