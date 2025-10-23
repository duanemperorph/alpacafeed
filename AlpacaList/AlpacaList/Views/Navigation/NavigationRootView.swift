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
    
    // Keep legacy support
    let legacyRootModel: PostsListViewModel?
    let useLegacyView: Bool
    
    init(rootModel: PostsListViewModel? = nil, useLegacyView: Bool = false) {
        self.legacyRootModel = rootModel
        self.useLegacyView = useLegacyView
    }
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.navigationStack) {
            Group {
                if useLegacyView, let rootModel = legacyRootModel {
                    // Legacy view for backwards compatibility
                    PostsFeedView(model: rootModel)
                } else {
                    // New Bluesky timeline view
                    TimelineView(viewModel: timelineViewModel)
                        .navigationTitle("Home")
                }
            }
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
