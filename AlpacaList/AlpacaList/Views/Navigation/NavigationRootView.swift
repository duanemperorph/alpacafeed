//
//  NavigationRootView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import SwiftUI

struct NavigationRootView: View {
    @State var rootModel: PostsListViewModel
    
    var body: some View {
        NavigationStack() {
            PostsFeedView(model: rootModel)
        }
        .navigationDestination(for: CommentsListViewModel.self) {
            CommentsFeedView(model: $0)
        }
    }
}

struct NavigationRootView_Previews: PreviewProvider {
    static let mockFeedItems = MockDataGenerator.generatePosts()
    
    static var previews: some View {
        let model = PostsListViewModel(rootPosts: mockFeedItems)
        NavigationRootView(rootModel: model)
    }
}
