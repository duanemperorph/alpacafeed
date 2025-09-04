//
//  NavigationRootView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import SwiftUI

struct NavigationRootView: View {
    @State var rootModel: PostsListViewModel
    @EnvironmentObject var navigationRootController: NavigationRootController
    @EnvironmentObject var topBarController: TopBarController
    
    var body: some View {
        NavigationStack(path: $navigationRootController.navigationStack) {
            PostsFeedView(model: rootModel)
            .navigationDestination(for: NavigationDestination.self) {
                navigationRootController.viewForDestination(destination: $0)
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
