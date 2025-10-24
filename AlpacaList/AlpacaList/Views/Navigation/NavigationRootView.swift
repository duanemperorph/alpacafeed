//
//  NavigationRootView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import SwiftUI

struct NavigationRootView: View {
    @StateObject private var timelineViewModel = TimelineViewModel.withMockData()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var topBarController: TopBarController
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.navigationStack) {
            TimelineView(viewModel: timelineViewModel)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    navigationCoordinator.viewForDestination(destination: destination)
                        .toolbar(.hidden)
                }
        }
        .safeAreaInset(edge: .top) {
            TopBarContainer()
        }
    }
}

struct NavigationRootView_Previews: PreviewProvider {
    static var previews: some View {
        return RootPreviews()
    }
}
