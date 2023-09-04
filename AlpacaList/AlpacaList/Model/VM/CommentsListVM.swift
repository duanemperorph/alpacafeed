//
//  CommentsListVM.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import Foundation

class CommentsListViewModel: ObservableObject, FeedItemViewModelListContainer {
    let postItem: FeedItem
    let postViewModel: FeedItemViewModel
    var comments: [FeedItemViewModel] = []
    @Published var visibleComments: [FeedItemViewModel] = []
    
    init(post: FeedItem) {
        self.postItem = post
        self.postViewModel = FeedItemViewModel(commentItem: post, style: .post)
        self.comments = post.children.map { FeedItemViewModel(commentItem: $0, style: .comment, containerDelegate: self) }
        updateVisibleComments()
    }
    
    // returns feed item for the current post item with all of the comments
    var postWithComments: [FeedItemViewModel] {
        return [postViewModel] + visibleComments
    }
    
    static func withMockData() -> CommentsListViewModel {
        let mockData = MockDataGenerator.generatePosts()
        return CommentsListViewModel(post: mockData[0])
    }
    
    func updateVisibleComments() {
        visibleComments = comments.flatMap ({ $0.selfWithRecursiveVisibleChildren })
    }
}
