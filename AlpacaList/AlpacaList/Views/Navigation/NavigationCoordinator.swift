//
//  NavigationCoordinator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/6/23.
//

import SwiftUI

enum NavigationDestination {
    case postDetails(postItem: FeedItem)
    case instanceSettings
    case userSettings
}

extension NavigationDestination: Hashable {
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.postDetails(let postItem1), .postDetails(let postItem2)):
            return postItem1.id == postItem2.id
        case (.instanceSettings, .instanceSettings):
            return true
        case (.userSettings, .userSettings):
            return true
        default:
            return false
        }
    
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .postDetails(let postItem):
            hasher.combine(postItem.id)
        case .instanceSettings:
            hasher.combine("instanceSettings")
        case .userSettings:
            hasher.combine("userSettings")
        }
    
    }
}

class NavigationCoordinator: ObservableObject {
    @Published var navigationStack: [NavigationDestination]
    
    init() {
        navigationStack = []
    }
    
    init(initialStack: [NavigationDestination]) {
        self.navigationStack = initialStack
    }
    
    var canPop: Bool {
        return navigationStack.count > 0
    }
    
    func push(_ destination: NavigationDestination) {
        navigationStack.append(destination)
    }
    
    func pop() {
        navigationStack.removeLast()
    }

    @ViewBuilder func viewForDestination(destination: NavigationDestination) -> some View {
        switch (destination) {
        case .postDetails(let postItem):
            let model = CommentsListViewModel(post: postItem)
            CommentsFeedView(model:model)
        case .instanceSettings:
            InstanceSettings()
        case .userSettings:
            UserSettings()
        }
    }
}
