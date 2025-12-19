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
    case timeline                            // Home timeline (feed type managed by ViewModel)
    case thread(post: Post)                  // Post thread (semantic: which post we're viewing)
    case profile(handle: String)             // User profile
}

// MARK: - Hashable Conformance

extension NavigationDestination: Hashable {
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.timeline, .timeline):
            return true
        case (.thread(let post1), .thread(let post2)):
            return post1.uri == post2.uri
        case (.profile(let handle1), .profile(let handle2)):
            return handle1 == handle2
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .timeline:
            hasher.combine("timeline")
        case .thread(let post):
            hasher.combine("thread")
            hasher.combine(post.uri)
        case .profile(let handle):
            hasher.combine("profile")
            hasher.combine(handle)
        }
    }
}

// MARK: - Navigation Coordinator

@Observable
@MainActor
class NavigationCoordinator {
    var navigationStack: [NavigationDestination]
    
    // Parallel ViewModel stack - mirrors navigationStack
    // Each ViewModel corresponds to the destination at the same index
    private var viewModelStack: [Any] = []
    
    // Current feed type for the home timeline (switching between Following, Discover, etc.)
    var currentFeedType: FeedType = .following
    
    // Cached ViewModels per feed type (lazy, one per feed)
    private var feedViewModels: [FeedType: TimelineViewModel] = [:]
    
    // Compose sheet state (for modal presentation)
    var showingComposeSheet: Bool = false
    var composeReplyTo: Post? = nil
    
    // Settings sheet state
    var showingSettingsSheet: Bool = false
    
    // Feed selector sheet state
    var showingFeedSelectorSheet: Bool = false
    
    // AppState for accessing ViewModelFactory
    private let appState: AppState
    
    init(appState: AppState) {
        self.navigationStack = []
        self.appState = appState
    }
    
    init(initialStack: [NavigationDestination], appState: AppState) {
        self.navigationStack = initialStack
        self.appState = appState
        // Note: initialStack ViewModels would need to be created here if used
    }
    
    var canPop: Bool {
        return navigationStack.count > 0
    }
    
    func push(_ destination: NavigationDestination) {
        // Create ViewModel for this destination and add to parallel stack
        let viewModel = createViewModel(for: destination)
        viewModelStack.append(viewModel)
        navigationStack.append(destination)
    }
    
    func pop() {
        navigationStack.removeLast()
        if !viewModelStack.isEmpty {
            viewModelStack.removeLast()
        }
    }
    
    func popToRoot() {
        navigationStack.removeAll()
        viewModelStack.removeAll()
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
    
    func presentFeedSelector() {
        showingFeedSelectorSheet = true
    }
    
    // MARK: - View Builders
    
    /// Default root view (Home timeline) - uses cached ViewModel for current feed type
    @ViewBuilder var rootView: some View {
        TimelineView(viewModel: getOrCreateFeedViewModel(for: currentFeedType))
    }
    
    /// Get cached ViewModel for a feed type or create one
    private func getOrCreateFeedViewModel(for feedType: FeedType) -> TimelineViewModel {
        if let cached = feedViewModels[feedType] {
            return cached
        }
        let newViewModel = appState.viewModelFactory.makeTimelineViewModel(for: feedType)
        feedViewModels[feedType] = newViewModel
        return newViewModel
    }
    
    @ViewBuilder var composeSheetView: some View {
        let viewModel = appState.viewModelFactory.makeComposeViewModel(replyTo: composeReplyTo)
        ComposeView(viewModel: viewModel)
    }
    
    /// Feed selector sheet binding for the current feed type
    var currentFeedTypeBinding: Binding<FeedType> {
        Binding(
            get: { self.currentFeedType },
            set: { self.currentFeedType = $0 }
        )
    }
    
    @ViewBuilder var feedSelectorSheetView: some View {
        FeedSelectorSheet(selectedFeed: currentFeedTypeBinding)
    }

    /// Build view for navigation destination using cached ViewModel from parallel stack
    @ViewBuilder func viewForDestination(destination: NavigationDestination) -> some View {
        // Look up cached ViewModel from parallel stack (search from top of stack)
        if let index = navigationStack.lastIndex(of: destination),
           index < viewModelStack.count {
            let cachedViewModel = viewModelStack[index]
            viewFromCachedViewModel(cachedViewModel, destination: destination)
        } else {
            // Fallback: create new ViewModel (shouldn't normally happen)
            viewFromNewViewModel(destination: destination)
        }
    }
    
    /// Build view using a cached ViewModel
    @ViewBuilder private func viewFromCachedViewModel(_ viewModel: Any, destination: NavigationDestination) -> some View {
        switch destination {
        case .timeline:
            if let vm = viewModel as? TimelineViewModel {
                TimelineView(viewModel: vm)
            }
            
        case .thread:
            if let vm = viewModel as? ThreadViewModel {
                ThreadView(viewModel: vm)
            }
            
        case .profile:
            if let vm = viewModel as? TimelineViewModel {
                TimelineView(viewModel: vm)
            }
        }
    }
    
    /// Fallback: Build view with a new ViewModel (used if cache lookup fails)
    @ViewBuilder private func viewFromNewViewModel(destination: NavigationDestination) -> some View {
        switch destination {
        case .timeline:
            let viewModel = appState.viewModelFactory.makeTimelineViewModel(feedType: .home)
            TimelineView(viewModel: viewModel)
            
        case .thread(let post):
            let viewModel = appState.viewModelFactory.makeThreadViewModel(post: post)
            ThreadView(viewModel: viewModel)
            
        case .profile(let handle):
            let viewModel = appState.viewModelFactory.makeTimelineViewModel(feedType: .authorFeed(handle: handle))
            TimelineView(viewModel: viewModel)
        }
    }
    
    // MARK: - ViewModel Creation
    
    /// Create a ViewModel for a navigation destination
    /// Called by push() to populate the parallel viewModelStack
    private func createViewModel(for destination: NavigationDestination) -> Any {
        switch destination {
        case .timeline:
            return appState.viewModelFactory.makeTimelineViewModel(feedType: .home)
            
        case .thread(let post):
            return appState.viewModelFactory.makeThreadViewModel(post: post)
            
        case .profile(let handle):
            return appState.viewModelFactory.makeTimelineViewModel(feedType: .authorFeed(handle: handle))
        }
    }
}
