//
//  FeedModelRoot.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/13/23.
//

import Foundation

/*
 struct FeedItem: Identifiable {
     let style: FeedItemStyle
     let id: UUID
     let username: String
     let date: Date
     
     let title: String?
     let body: String?
     let thumbnail: String?
 */

class CommentViewModel: ObservableObject {
    @Published var isExpanded: Bool = false
    let indention: Int
    let commentItem: FeedItem
    let children: [CommentViewModel]
    
    init(commentItem: FeedItem, indention: Int = 0) {
        self.indention = indention
        self.commentItem = commentItem
        self.children = commentItem.children.map { CommentViewModel(commentItem: $0, indention: indention + 1) }
    }
    
    var visibleChildren: [CommentViewModel] {
        if isExpanded {
            return children
        } else {
            return []
        }
    }
    
    var recursiveVisibleChildren: [CommentViewModel] {
        var visibleChildren = [CommentViewModel]()
        for child in children {
            visibleChildren.append(child)
            visibleChildren.append(contentsOf: child.recursiveVisibleChildren)
        }
        return visibleChildren
    }
    
    var selfWithRecursiveVisibleChildren: [CommentViewModel] {
        return [self] + recursiveVisibleChildren
    }
}

class CommentsListViewModel: ObservableObject {
    let postItem: FeedItem
    let comments: [CommentViewModel]
    
    init(post: FeedItem) {
        self.postItem = post
        self.comments = post.children.map { CommentViewModel(commentItem: $0) }
    }
    
    var visibleComments: [CommentViewModel] {
        return comments.flatMap ({ $0.selfWithRecursiveVisibleChildren })
    }
    
    static func withMockData() -> CommentsListViewModel {
        let mockData = MockDataGenerator.generatePosts()
        return CommentsListViewModel(post: mockData[0])
    }
}

class PostsListViewModel {
    let rootPostItems: [FeedItem]
 
    init(rootPosts: [FeedItem]) {
        self.rootPostItems = rootPosts
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
