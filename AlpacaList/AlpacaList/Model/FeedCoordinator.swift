//
//  FeedCoordinator.swift
//  AlpacaList
//
//  Created by AppCoordinator Pattern Refactoring
//

import SwiftUI

// MARK: - Feed Routes

enum FeedRoute: Hashable {
    case postDetails(postItem: FeedItem)
    
    // Hashable conformance
    static func == (lhs: FeedRoute, rhs: FeedRoute) -> Bool {
        switch (lhs, rhs) {
        case (.postDetails(let postItem1), .postDetails(let postItem2)):
            return postItem1.id == postItem2.id
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .postDetails(let postItem):
            hasher.combine(postItem.id)
        }
    }
}

// MARK: - Feed Coordinator

class FeedCoordinator: Coordinator {
    typealias RouteType = FeedRoute
    
    // MARK: - Published Properties
    @Published var navigationPath: [FeedRoute] = []
    
    // MARK: - Dependencies
    var parentCoordinator: AppCoordinator?
    var postsListViewModel: PostsListViewModel?
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Feed coordinator starts clean - main feed is shown by default
    }
    
    @ViewBuilder 
    func view(for route: FeedRoute) -> AnyView {
        switch route {
        case .postDetails(let postItem):
            AnyView(makePostDetailsView(for: postItem))
        }
    }
    
    // MARK: - Public Methods
    
    func showPostDetails(for postItem: FeedItem) {
        navigate(to: .postDetails(postItem: postItem))
    }
    
    func showSettings() {
        parentCoordinator?.showSettings()
    }
    
    // MARK: - Private Methods
    
    private func makePostDetailsView(for postItem: FeedItem) -> some View {
        let commentsViewModel = CommentsListViewModel(post: postItem)
        return CommentsFeedView(model: commentsViewModel)
            .toolbar(.hidden)
    }
}

// MARK: - Feed Coordinator View

struct FeedCoordinatorView: View {
    @ObservedObject var coordinator: FeedCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            PostsFeedView(model: coordinator.postsListViewModel!)
                .navigationDestination(for: FeedRoute.self) { route in
                    coordinator.view(for: route)
                }
        }
        .environmentObject(coordinator)
    }
} 