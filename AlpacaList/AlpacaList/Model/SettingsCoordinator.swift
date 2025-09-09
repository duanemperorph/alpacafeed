//
//  SettingsCoordinator.swift
//  AlpacaList
//
//  Created by AppCoordinator Pattern Refactoring
//

import SwiftUI

// MARK: - Settings Routes

enum SettingsRoute: Hashable {
    case instanceSettings
    case userSettings
}

// MARK: - Settings Coordinator

class SettingsCoordinator: Coordinator {
    typealias RouteType = SettingsRoute
    
    // MARK: - Published Properties
    @Published var navigationPath: [SettingsRoute] = []
    
    // MARK: - Dependencies
    var parentCoordinator: AppCoordinator?
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Settings coordinator starts clean - main settings view would be shown
    }
    
    @ViewBuilder 
    func view(for route: SettingsRoute) -> AnyView {
        switch route {
        case .instanceSettings:
            AnyView(makeInstanceSettingsView())
        case .userSettings:
            AnyView(makeUserSettingsView())
        }
    }
    
    // MARK: - Public Methods
    
    func showInstanceSettings() {
        navigate(to: .instanceSettings)
    }
    
    func showUserSettings() {
        navigate(to: .userSettings)
    }
    
    func showFeed() {
        parentCoordinator?.showFeed()
    }
    
    // MARK: - Private Methods
    
    private func makeInstanceSettingsView() -> some View {
        InstanceSettings()
            .toolbar(.hidden)
    }
    
    private func makeUserSettingsView() -> some View {
        UserSettings()
            .toolbar(.hidden)
    }
}

// MARK: - Settings Coordinator View

struct SettingsCoordinatorView: View {
    @ObservedObject var coordinator: SettingsCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            // TODO: Create a main settings view that shows options
            // For now, we'll show instance settings as the default
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button("Instance Settings") {
                    coordinator.showInstanceSettings()
                }
                .buttonStyle(.borderedProminent)
                
                Button("User Settings") {
                    coordinator.showUserSettings()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationDestination(for: SettingsRoute.self) { route in
                coordinator.view(for: route)
            }
        }
        .environmentObject(coordinator)
    }
} 