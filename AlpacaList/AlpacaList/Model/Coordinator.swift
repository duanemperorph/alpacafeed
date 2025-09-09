//
//  Coordinator.swift
//  AlpacaList
//
//  Created by AppCoordinator Pattern Refactoring
//

import SwiftUI

// MARK: - Base Coordinator Protocol

/// Base protocol for all coordinators in the app
protocol Coordinator: ObservableObject {
    associatedtype RouteType: Hashable
    
    /// Current navigation path for this coordinator
    var navigationPath: [RouteType] { get set }
    
    /// Start the coordinator's flow
    func start()
    
    /// Navigate to a specific route
    func navigate(to route: RouteType)
    
    /// Pop the last route from navigation stack
    func pop()
    
    /// Pop to root (clear navigation stack)
    func popToRoot()
    
    /// Create view for a given route
    @ViewBuilder func view(for route: RouteType) -> AnyView
}

// MARK: - Default Implementations

extension Coordinator {
    func navigate(to route: RouteType) {
        navigationPath.append(route)
    }
    
    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        navigationPath.removeAll()
    }
    
    var canPop: Bool {
        return !navigationPath.isEmpty
    }
}

// MARK: - Coordinator Factory Protocol

/// Protocol for creating and managing child coordinators
protocol CoordinatorFactory {
    func makeAppCoordinator() -> AppCoordinator
    func makeFeedCoordinator() -> FeedCoordinator
    func makeSettingsCoordinator() -> SettingsCoordinator
} 