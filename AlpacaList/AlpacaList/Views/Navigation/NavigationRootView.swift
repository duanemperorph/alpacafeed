//
//  NavigationRootView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import SwiftUI

struct NavigationRootView: View {
    @Environment(TopBarController.self) private var topBarController
    
    // NavigationCoordinator passed via dependency injection
    let navigationCoordinator: NavigationCoordinator
    
    init(navigationCoordinator: NavigationCoordinator) {
        self.navigationCoordinator = navigationCoordinator
    }
    
    var body: some View {
        @Bindable var navigationCoordinator = navigationCoordinator
        NavigationStack(path: $navigationCoordinator.navigationStack) {
            // Root view provided by NavigationCoordinator
            navigationCoordinator.rootView
                .navigationDestination(for: NavigationDestination.self) { destination in
                    navigationCoordinator.viewForDestination(destination: destination)
                }
        }
        .safeAreaInset(edge: .top) {
            TopBarContainer()
        }
        .sheet(isPresented: $navigationCoordinator.showingComposeSheet) {
            navigationCoordinator.composeSheetView
        }
        .sheet(isPresented: $navigationCoordinator.showingSettingsSheet) {
            UserSettings()
        }
        .environment(navigationCoordinator)
    }
}

struct NavigationRootView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let navigationCoordinator = NavigationCoordinator(appState: appState)
        let topBarController = TopBarController()
        
        return NavigationRootView(navigationCoordinator: navigationCoordinator)
            .environment(appState)
            .environment(topBarController)
    }
}
