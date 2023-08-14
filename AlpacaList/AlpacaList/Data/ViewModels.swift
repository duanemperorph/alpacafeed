//
//  FeedModelRoot.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/13/23.
//

import Foundation

class CommentsViewModel: ObservableObject {
    @Published var post: FeedItem
    
    init(post: FeedItem) {
        self.post = post
    }
    
    func toggleExpandedForCommentWithId(id: UUID) {
        guard var children = post.children else { return }
        
        let didMutate = children.recursiveFindAndMutateItem(withId: id) { item in
            item.isExpanded.toggle()
        }
        
        if didMutate {
            print("didMutate")
            var newPost = post
            newPost.children = children
            post = newPost
            printExpanded()
        }
    }
    
    func printExpanded() {
        guard let children = post.children else { return }
        
        for item in children {
            print("isExpanded: ", item.isExpanded)
        }
    }
    
    static func withMockData() -> CommentsViewModel {
        let mockData = MockDataGenerator.generatePosts()
        return CommentsViewModel(post: mockData[0])
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
    
    static func withMockData() -> PostsViewModel {
        let mockData = MockDataGenerator.generatePosts()
        return PostsViewModel(rootPosts: mockData)
    }
}
