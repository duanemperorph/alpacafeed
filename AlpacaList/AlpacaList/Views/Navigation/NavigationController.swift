//
//  NavigationController.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/6/23.
//

import Foundation

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
