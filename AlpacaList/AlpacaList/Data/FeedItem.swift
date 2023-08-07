//
//  FeedItem.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import Foundation

enum FeedItemStyle {
    case post
    case comment
}

struct FeedItem: Identifiable {
    let style: FeedItemStyle
    let id: UUID
    let username: String
    let date: Date
    
    let title: String?
    let body: String?
    let thumbnail: String?
    
    let children: [FeedItem]?
    let indention: Int?
    let isExpaneded: Bool = false
    
    static func createPost(id: UUID, username: String, date: Date, title: String, body: String?, thumbnail: String?, children: [FeedItem]) -> FeedItem {
        // Create a new feed item
        return FeedItem(style: .post, id: id, username: username, date: date, title: title, body: body, thumbnail: thumbnail, children: children, indention: nil)
        
    }
    
    static func createComment(id: UUID, username: String, date: Date, body: String, indention: Int, children: [FeedItem]) -> FeedItem {
        // Create a new feed item
        return FeedItem(style: .comment, id: id, username: username, date: date, title: nil, body: body, thumbnail: nil, children: children, indention: indention)
    
    }
}
