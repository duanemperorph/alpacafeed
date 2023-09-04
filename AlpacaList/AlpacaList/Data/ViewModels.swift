//
//  FeedModelRoot.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/13/23.
//

import Foundation

/*
 struct FeedItem: Identifiable {
     let id: UUID
     let username: String
     let date: Date
     
     let title: String?
     let body: String?
     let thumbnail: String?
 */

enum FeedItemStyle {
    case post
    case comment
}

protocol FeedItemViewModelListContainer: AnyObject {
    func updateVisibleComments()
}

class FeedItemViewModel: ObservableObject, Identifiable {
    @Published var isExpanded: Bool = false {
        didSet {
            containerDelegate?.updateVisibleComments()
        }
    }
    let style: FeedItemStyle
    let indention: Int
    let feedItem: FeedItem
    let children: [FeedItemViewModel]
    
    weak var containerDelegate: FeedItemViewModelListContainer?
    
    var id: UUID {
        return feedItem.id
    }
    
    init(commentItem: FeedItem, style: FeedItemStyle, containerDelegate: FeedItemViewModelListContainer? = nil, indention: Int = 0) {
        self.style = style
        self.indention = indention
        self.feedItem = commentItem
        self.containerDelegate = containerDelegate
        self.children = commentItem.children.map { FeedItemViewModel(commentItem: $0, style: .comment, containerDelegate: containerDelegate, indention: indention + 1) }
    }
    
    var visibleChildren: [FeedItemViewModel] {
        if isExpanded {
            return children
        } else {
            return []
        }
    }
    
    var recursiveVisibleChildren: [FeedItemViewModel] {
        guard isExpanded else { return [] }
        
        var visibleChildren = [FeedItemViewModel]()
        
        for child in children {
            visibleChildren.append(child)
            visibleChildren.append(contentsOf: child.recursiveVisibleChildren)
        }
        return visibleChildren
    }
    
    var selfWithRecursiveVisibleChildren: [FeedItemViewModel] {
        return [self] + recursiveVisibleChildren
    }
}

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

extension CommentsListViewModel: Hashable {
    static func == (lhs: CommentsListViewModel, rhs: CommentsListViewModel) -> Bool {
        return lhs.postItem.id == rhs.postItem.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(postItem.id)
    }
}

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
