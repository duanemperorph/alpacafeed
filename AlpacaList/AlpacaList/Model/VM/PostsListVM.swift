//
//  FeedModelRoot.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/13/23.
//

import Foundation

class PostsListViewModel {
    let rootPostItems: [FeedItem]
 
    init(rootPosts: [FeedItem]) {
        self.rootPostItems = rootPosts
    }
    
    var posts: [FeedItemViewModel] {
        return rootPostItems.map { FeedItemViewModel(commentItem: $0, style: .post) }
    }
    
    func getCommentsViewModelForPost(withId: UUID) -> CommentsListViewModel? {
        if let post = rootPostItems.first(where: { $0.id == withId }) {
            return CommentsListViewModel(post: post)
        }
        else {
            return nil
        }
    }
    
    static func withMockData() -> PostsListViewModel {
        let mockData = MockDataGenerator.generatePosts()
        return PostsListViewModel(rootPosts: mockData)
    }
}
