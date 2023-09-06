//
//  AlpacaListApp.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

@main
struct AlpacaListApp: App {
    let mockFeedItems = MockDataGenerator.generatePosts()
    let navigationRootController: NavigationRootController = NavigationRootController()
    
    var body: some Scene {
        let model = PostsListViewModel(rootPosts: mockFeedItems)
        WindowGroup {
            PostsFeedView(model: model)
        }
    }
}
