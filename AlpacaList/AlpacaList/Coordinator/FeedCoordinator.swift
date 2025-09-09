//
//  FeedCoordinator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on [date]
//

import SwiftUI

enum FeedDestination: Hashable {
    case postDetails(postItem: FeedItem)
}

class FeedCoordinator: Coordinator {
    typealias ContentView = FeedCoordinatorView
    
    @Published var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?
    
    @Published var navigationStack: [FeedDestination] = []
    
    // Models and data
    private let mockFeedItems = MockDataGenerator.generatePosts()
    private var postsListViewModel: PostsListViewModel?
    
    func start() {
        // Initialize the feed with mock data
        postsListViewModel = PostsListViewModel(rootPosts: mockFeedItems)
    }
    
    func createView() -> FeedCoordinatorView {
        return FeedCoordinatorView(coordinator: self)
    }
    
    // MARK: - Navigation Methods
    
    func showPostDetails(postItem: FeedItem) {
        navigationStack.append(.postDetails(postItem: postItem))
    }
    
    func pop() {
        if !navigationStack.isEmpty {
            navigationStack.removeLast()
        }
    }
    
    var canPop: Bool {
        return !navigationStack.isEmpty
    }
    
    // MARK: - View Creation
    
    @ViewBuilder func viewForDestination(destination: FeedDestination) -> some View {
        switch destination {
        case .postDetails(let postItem):
            let model = CommentsListViewModel(post: postItem)
            CommentsFeedView(model: model)
        }
    }
    
    func getRootModel() -> PostsListViewModel {
        return postsListViewModel ?? PostsListViewModel(rootPosts: mockFeedItems)
    }
}

// MARK: - FeedCoordinator View

struct FeedCoordinatorView: View {
    @ObservedObject var coordinator: FeedCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationStack) {
            PostsFeedView(model: coordinator.getRootModel())
                .navigationDestination(for: FeedDestination.self) {
                    coordinator.viewForDestination(destination: $0)
                        .toolbar(.hidden)
                }
        }
        .safeAreaInset(edge: .top) {
            TopBarContainer()
        }
    }
} 
