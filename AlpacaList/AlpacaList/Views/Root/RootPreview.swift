//
//  Previews.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/6/23.
//

import SwiftUI

struct RootPreviews: View {
    let mockFeedItems = MockDataGenerator.generatePosts()
    let navigationRootController: NavigationRootController = NavigationRootController()
    let topBarController: TopBarController = TopBarController()
    
    var body: some View {
        let model = PostsListViewModel(rootPosts: mockFeedItems)
        NavigationRootView(rootModel: model)
            .environmentObject(navigationRootController)
            .environmentObject(topBarController)
    }
}

struct Previews_Previews: PreviewProvider {
    static var previews: some View {
        RootPreviews()
    }
}
