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

class FeedItemViewModel: ObservableObject, Identifiable {
    let style: FeedItemStyle
    let indention: Int
    let feedItem: FeedItem
    let children: [FeedItemViewModel]
    
    var id: UUID {
        return feedItem.id
    }
    
    init(commentItem: FeedItem, style: FeedItemStyle, indention: Int = 0) {
        self.style = style
        self.indention = indention
        self.feedItem = commentItem
        self.children = commentItem.children.map { FeedItemViewModel(commentItem: $0, style: .comment, indention: indention + 1) }
    }
}
