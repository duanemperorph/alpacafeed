//
//  AppCoordinator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on [date]
//

import SwiftUI

enum AppFlow: Hashable {
    case feed
    case settings
}

class AppCoordinator: Coordinator {
    typealias ContentView = AppCoordinatorView
    
    @Published var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?
    
    @Published var currentFlow: AppFlow = .feed
    
    // Child coordinators
    private var feedCoordinator: FeedCoordinator?
    private var settingsCoordinator: SettingsCoordinator?
    
    // Controllers from existing system
    let topBarController: TopBarController
    
    init() {
        self.topBarController = TopBarController()
    }
    
    func start() {
        // Initialize with feed flow
        showFeed()
    }
    
    func createView() -> AppCoordinatorView {
        return AppCoordinatorView(coordinator: self)
    }
    
    // MARK: - Navigation Methods
    
    func showFeed() {
        currentFlow = .feed
        
        if feedCoordinator == nil {
            feedCoordinator = FeedCoordinator()
            addChild(feedCoordinator!)
        }
        feedCoordinator?.start()
    }
    
    func showSettings() {
        currentFlow = .settings
        
        if settingsCoordinator == nil {
            settingsCoordinator = SettingsCoordinator()
            addChild(settingsCoordinator!)
        }
        settingsCoordinator?.start()
    }
    
    // MARK: - Helper Methods
    
    func getCurrentCoordinator() -> (any Coordinator)? {
        switch currentFlow {
        case .feed:
            return feedCoordinator
        case .settings:
            return settingsCoordinator
        }
    }
}

// MARK: - AppCoordinator View

struct AppCoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            switch coordinator.currentFlow {
            case .feed:
                if let feedCoordinator = coordinator.childCoordinators.first(where: { $0 is FeedCoordinator }) as? FeedCoordinator {
                    AnyView(feedCoordinator.createView())
                        .environmentObject(coordinator.topBarController)
                        .environmentObject(feedCoordinator)
                }
            case .settings:
                if let settingsCoordinator = coordinator.childCoordinators.first(where: { $0 is SettingsCoordinator }) as? SettingsCoordinator {
                    AnyView(settingsCoordinator.createView())
                        .environmentObject(coordinator.topBarController)
                        .environmentObject(settingsCoordinator)
                }
            }
        }
        .environmentObject(coordinator)
    }
} 