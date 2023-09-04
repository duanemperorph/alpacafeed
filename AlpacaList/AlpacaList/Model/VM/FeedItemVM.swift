//
//  VM.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/4/23.
//

import Foundation

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
