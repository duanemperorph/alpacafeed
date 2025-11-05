//
//  NavigationCoordinator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/6/23.
//

import SwiftUI
import Observation

// MARK: - Navigation Destination

/// Navigation destinations for the app
enum NavigationDestination {
    // Bluesky navigation
    case timeline(type: TimelineType)        // Home, profile, custom feed
    case thread(post: Post)                  // Post thread (semantic: which post we're viewing)
    case profile(handle: String)             // User profile
    case compose(replyTo: Post?)             // New post/reply
    case quotePost(post: Post)               // Quote post composer
    
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
        // Bluesky
        case (.timeline(let type1), .timeline(let type2)):
            return type1 == type2
        case (.thread(let post1), .thread(let post2)):
            return post1.uri == post2.uri
        case (.profile(let handle1), .profile(let handle2)):
            return handle1 == handle2
        case (.compose(let post1), .compose(let post2)):
            return post1?.id == post2?.id
        case (.quotePost(let post1), .quotePost(let post2)):
            return post1.id == post2.id
            
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        // Bluesky
        case .timeline(let type):
            hasher.combine("timeline")
            hasher.combine(type)
        case .thread(let post):
            hasher.combine("thread")
            hasher.combine(post.uri)
        case .profile(let handle):
            hasher.combine("profile")
            hasher.combine(handle)
        case .compose(let post):
            hasher.combine("compose")
            hasher.combine(post?.id)
        case .quotePost(let post):
            hasher.combine("quotePost")
            hasher.combine(post.id)
        }
    }
}

// MARK: - Navigation Coordinator

@Observable
class NavigationCoordinator {
    var navigationStack: [NavigationDestination]
    
    // Compose sheet state (for modal presentation)
    var showingComposeSheet: Bool = false
    var composeReplyTo: Post? = nil
    
    // Settings sheet state
    var showingSettingsSheet: Bool = false
    
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
    
    func presentCompose(replyTo: Post? = nil) {
        composeReplyTo = replyTo
        showingComposeSheet = true
    }
    
    func presentComposeContextAware() {
        // If we're in a thread view, reply to the thread's root post
        // Otherwise, create a new post
        // Read semantic state from navigation stack
        if case .thread(let post) = navigationStack.last {
            composeReplyTo = post
        } else {
            composeReplyTo = nil
        }
        showingComposeSheet = true
    }
    
    func presentSettings() {
        showingSettingsSheet = true
    }

    @ViewBuilder func viewForDestination(destination: NavigationDestination) -> some View {
        switch destination {
        // Bluesky navigation
        case .timeline(let type):
            let viewModel = TimelineViewModel(timelineType: timelineTypeFromDestination(type))
            TimelineView(viewModel: viewModel)
            
        case .thread(let post):
            // Initialize with the post we're viewing (semantic state!)
            let viewModel = ThreadViewModel.withMockData(for: post)
            ThreadView(viewModel: viewModel)
            
        case .profile(let handle):
            // TODO: Create ProfileView
            let viewModel = TimelineViewModel(timelineType: .authorFeed(handle: handle))
            TimelineView(viewModel: viewModel)
            
        case .compose(let replyTo):
            ComposeView(replyTo: replyTo)
            
        case .quotePost(let post):
            // TODO: Create QuotePostView
            Text("Quote post: \(post.text)")
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
