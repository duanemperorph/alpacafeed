//
//  NavigationRootView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import SwiftUI

struct NavigationRootView: View {
    @State private var timelineViewModel = TimelineViewModel.withMockData()
    @Environment(NavigationCoordinator.self) private var navigationCoordinator
    @Environment(TopBarController.self) private var topBarController
    
    var body: some View {
        @Bindable var navigationCoordinator = navigationCoordinator
        NavigationStack(path: $navigationCoordinator.navigationStack) {
            TimelineView(viewModel: timelineViewModel)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    navigationCoordinator.viewForDestination(destination: destination)
                }
        }
        .safeAreaInset(edge: .top) {
            TopBarContainer()
        }
        .sheet(isPresented: $navigationCoordinator.showingComposeSheet) {
            ComposeView(replyTo: navigationCoordinator.composeReplyTo)
        }
        .sheet(isPresented: $navigationCoordinator.showingSettingsSheet) {
            UserSettings()
        }
    }
}

struct NavigationRootView_Previews: PreviewProvider {
    static var previews: some View {
        return RootPreviews()
    }
}
