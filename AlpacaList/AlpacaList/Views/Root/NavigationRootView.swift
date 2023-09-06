//
//  NavigationRootView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import SwiftUI

enum NavigationDestination {
    case postDetails(postItem: FeedItem)
//    case instanceSettings
//    case userSettings
}

extension NavigationDestination: Hashable {
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.postDetails(let lhsPost), .postDetails(let rhsPost)):
            return lhsPost.id == rhsPost.id
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .postDetails(let postItem):
            hasher.combine(postItem.id)
        }
    }
}

class NavigationRootController: ObservableObject {
    @Published var navigationStack: [NavigationDestination] = []
    
    func push(_ destination: NavigationDestination) {
        navigationStack.append(destination)
    }
    
    func pop() {
        navigationStack.removeLast()
    }

}

struct NavigationRootView: View {
    @State var rootModel: PostsListViewModel
    @EnvironmentObject var navigationRootController: NavigationRootController
    
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
    }
}

struct NavigationRootView_Previews: PreviewProvider {
    static var previews: some View {
        return RootPreviews()
    }
}
