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
            .navigationDestination(for: NavigationDestination.self) { dest in
                switch dest {
                case .postDetails(let postItem):
                    let model = CommentsListViewModel(post: postItem)
                    CommentsFeedView(model:model)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            TopBarContainer(isOpen: $topBarController.isExpanded)
        }
    }
}

struct NavigationRootView_Previews: PreviewProvider {
    static var previews: some View {
        return RootPreviews()
    }
}
