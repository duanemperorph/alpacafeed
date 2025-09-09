//
//  AppCoordinator.swift
//  AlpacaList
//
//  Created by AppCoordinator Pattern Refactoring
//

import SwiftUI

// MARK: - App Routes

enum AppRoute: Hashable {
    case feed
    case settings
}

// MARK: - App Coordinator

class AppCoordinator: Coordinator {
    typealias RouteType = AppRoute
    
    // MARK: - Published Properties
    @Published var navigationPath: [AppRoute] = []
    @Published var topBarController = TopBarController()
    
    // MARK: - Child Coordinators
    private var feedCoordinator: FeedCoordinator?
    private var settingsCoordinator: SettingsCoordinator?
    
    // MARK: - Dependencies
    private let coordinatorFactory: CoordinatorFactory
    private let postsListViewModel: PostsListViewModel
    
    // MARK: - Initialization
    
    init(coordinatorFactory: CoordinatorFactory, postsListViewModel: PostsListViewModel) {
        self.coordinatorFactory = coordinatorFactory
        self.postsListViewModel = postsListViewModel
    }
    
    convenience init() {
        let factory = DefaultCoordinatorFactory()
        let viewModel = PostsListViewModel.withMockData()
        self.init(coordinatorFactory: factory, postsListViewModel: viewModel)
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Start with feed as the default route
        navigate(to: .feed)
    }
    
    @ViewBuilder 
    func view(for route: AppRoute) -> AnyView {
        switch route {
        case .feed:
            AnyView(makeFeedView())
        case .settings:
            AnyView(makeSettingsView())
        }
    }
    
    // MARK: - Public Methods
    
    func showSettings() {
        navigate(to: .settings)
    }
    
    func showFeed() {
        navigate(to: .feed)
    }
    
    // MARK: - Private Methods
    
    private func makeFeedView() -> some View {
        if feedCoordinator == nil {
            feedCoordinator = coordinatorFactory.makeFeedCoordinator()
            feedCoordinator?.parentCoordinator = self
            feedCoordinator?.postsListViewModel = postsListViewModel
        }
        feedCoordinator?.start()
        return FeedCoordinatorView(coordinator: feedCoordinator!)
    }
    
    private func makeSettingsView() -> some View {
        if settingsCoordinator == nil {
            settingsCoordinator = coordinatorFactory.makeSettingsCoordinator()
            settingsCoordinator?.parentCoordinator = self
        }
        settingsCoordinator?.start()
        return SettingsCoordinatorView(coordinator: settingsCoordinator!)
    }
}

// MARK: - Default Coordinator Factory

class DefaultCoordinatorFactory: CoordinatorFactory {
    func makeAppCoordinator() -> AppCoordinator {
        return AppCoordinator()
    }
    
    func makeFeedCoordinator() -> FeedCoordinator {
        return FeedCoordinator()
    }
    
    func makeSettingsCoordinator() -> SettingsCoordinator {
        return SettingsCoordinator()
    }
} 