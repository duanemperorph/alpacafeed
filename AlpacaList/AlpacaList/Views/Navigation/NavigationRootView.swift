//
//  NavigationRootView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import SwiftUI

struct NavigationRootView: View {
    @Environment(AppState.self) private var appState
    @Environment(TopBarController.self) private var topBarController
    
    var body: some View {
        @Bindable var navigationCoordinator = appState.navigationCoordinator
        
        NavigationStack(path: $navigationCoordinator.navigationStack) {
            // Root view - shows placeholder until session is restored, then timeline
            rootContent
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
        .sheet(isPresented: $navigationCoordinator.showingFeedSelectorSheet) {
            navigationCoordinator.feedSelectorSheetView
        }
        .environment(appState.navigationCoordinator)
    }
    
    @ViewBuilder
    private var rootContent: some View {
        if !appState.isSessionRestored {
            // Placeholder while restoring session
            Color.clear
        } else if !appState.isAuthenticated {
            // Unauthenticated - show empty for now (login handled via settings)
            Color.clear
        } else {
            // Authenticated - show timeline
            appState.navigationCoordinator.timelineView
        }
    }
}

struct NavigationRootView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let topBarController = TopBarController()
        
        return NavigationRootView()
            .environment(appState)
            .environment(topBarController)
    }
}
