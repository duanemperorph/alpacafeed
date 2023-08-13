//
//  FeedModelRoot.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/13/23.
//

import Foundation

class CommentsViewModel {
    var post: FeedItem
    
    init(post: FeedItem) {
        self.post = post
    }
    
    func toggleExpandedForCommentWithId(id: UUID) {
        if var foundItem = post.children?.recursiveFindItem(withId: id) {
            foundItem.isExpanded.toggle()
        }
    }
    
    var expandedComments: [FeedItem] {
        
    }
}

class PostsViewModel {
    let rootPosts: [FeedItem]
 
    init(rootPosts: [FeedItem]) {
        self.rootPosts = rootPosts
    }
    
    func getCommentsViewModelForPost(withId: UUID) -> CommentsViewModel? {
        if let post = rootPosts.first(where: { $0.id == withId }) {
            return CommentsViewModel(post: post)
        }
        else {
            return nil
        }
    }
}
