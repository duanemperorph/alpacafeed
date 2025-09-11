//
//  CommentsListVM.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import Foundation
import Combine

class CommentsListViewModel: ObservableObject {
    let postItem: FeedItem
    let postViewModel: FeedItemViewModel
    var comments: [FeedItemViewModel] = []
    @Published var visibleComments: [FeedItemViewModel] = [] {
        didSet {
            print("updated visible comments with \(visibleComments.count)")
        }
    }
    @Published private(set) var expandedIds: Set<UUID> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(post: FeedItem) {
        self.postItem = post
        self.postViewModel = FeedItemViewModel(commentItem: post, style: .post)
        self.comments = post.children.map { FeedItemViewModel(commentItem: $0, style: .comment) }
        
        // Set up reactive visible comments calculation
        setupReactiveVisibleComments()
    }
    
    private func setupReactiveVisibleComments() {
        $expandedIds
            .map { [weak self] newIds in
                guard let self = self else { return [] }
                let newItems =  self.flatten(items: self.comments, expandedIds: newIds)
                print("calculated new flatteded items: \(newItems.count)")
                return newItems
            }
            .assign(to: &$visibleComments)
    }
    
    // returns feed item for the current post item with all of the comments
    var postWithComments: [FeedItemViewModel] {
        return [postViewModel] + visibleComments
    }
    
    static func withMockData() -> CommentsListViewModel {
        let mockData = MockDataGenerator.generatePosts()
        return CommentsListViewModel(post: mockData[0])
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
        // No need to call updateVisibleComments() - it's now reactive!
    }

    private func flatten(items: [FeedItemViewModel], expandedIds: Set<UUID>) -> [FeedItemViewModel] {
        var result: [FeedItemViewModel] = []
        for item in items {
            result.append(item)
            if expandedIds.contains(item.id) {
                result.append(contentsOf: flatten(items: item.children, expandedIds: expandedIds))
            }
        }
        return result
    }
}
