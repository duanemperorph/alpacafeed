//
//  SettingsCoordinator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on [date]
//

import SwiftUI

enum SettingsDestination: Hashable {
    case instanceSettings
    case userSettings
}

class SettingsCoordinator: Coordinator {
    typealias ContentView = SettingsCoordinatorView
    
    @Published var childCoordinators: [any Coordinator] = []
    var parent: (any Coordinator)?
    
    @Published var navigationStack: [SettingsDestination] = []
    
    func start() {
        // Initialize settings if needed
    }
    
    func createView() -> SettingsCoordinatorView {
        return SettingsCoordinatorView(coordinator: self)
    }
    
    // MARK: - Navigation Methods
    
    func showInstanceSettings() {
        navigationStack.append(.instanceSettings)
    }
    
    func showUserSettings() {
        navigationStack.append(.userSettings)
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
    
    @ViewBuilder func viewForDestination(destination: SettingsDestination) -> some View {
        switch destination {
        case .instanceSettings:
            InstanceSettings()
        case .userSettings:
            UserSettings()
        }
    }
}

// MARK: - SettingsCoordinator View

struct SettingsCoordinatorView: View {
    @ObservedObject var coordinator: SettingsCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationStack) {
            // Show a main settings view that can navigate to specific settings
            MainSettingsView()
                .navigationDestination(for: SettingsDestination.self) {
                    coordinator.viewForDestination(destination: $0)
                        .toolbar(.hidden)
                }
        }
        .safeAreaInset(edge: .top) {
            TopBarContainer()
        }
    }
}

// Temporary main settings view - you can replace this with your actual settings menu
struct MainSettingsView: View {
    @EnvironmentObject var settingsCoordinator: SettingsCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Instance Settings") {
                settingsCoordinator.showInstanceSettings()
            }
            .padding()
            
            Button("User Settings") {
                settingsCoordinator.showUserSettings()
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Settings")
    }
} 