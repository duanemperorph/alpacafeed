//
//  CommentsListVM.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import Foundation

class CommentsListViewModel: ObservableObject {
    let postItem: FeedItem
    let postViewModel: FeedItemViewModel
    var comments: [FeedItemViewModel] = []
    @Published var visibleComments: [FeedItemViewModel] = []
    @Published private(set) var expandedIds: Set<UUID> = []
    
    init(post: FeedItem) {
        self.postItem = post
        self.postViewModel = FeedItemViewModel(commentItem: post, style: .post)
        self.comments = post.children.map { FeedItemViewModel(commentItem: $0, style: .comment) }
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
        print("update visible comments")
        visibleComments = flatten(items: comments)
    }

    func isExpanded(id: UUID) -> Bool {
        return expandedIds.contains(id)
    }

    func toggleExpanded(id: UUID) {
        if expandedIds.contains(id) {
            expandedIds.remove(id)
        } else {
            expandedIds.insert(id)
        }
        updateVisibleComments()
    }

    private func flatten(items: [FeedItemViewModel]) -> [FeedItemViewModel] {
        var result: [FeedItemViewModel] = []
        for item in items {
            result.append(item)
            if expandedIds.contains(item.id) {
                result.append(contentsOf: flatten(items: item.children))
            }
        }
        return result
    }
}
