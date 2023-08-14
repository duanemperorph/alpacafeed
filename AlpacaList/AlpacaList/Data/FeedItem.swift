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
    
    var children: [FeedItem]?
    let indention: Int?
    var isExpanded: Bool = false
    
    static func createPost(id: UUID, username: String, date: Date, title: String, body: String?, thumbnail: String?, children: [FeedItem]) -> FeedItem {
        // Create a new feed item
        return FeedItem(style: .post, id: id, username: username, date: date, title: title, body: body, thumbnail: thumbnail, children: children, indention: nil)
        
    }
    
    static func createComment(id: UUID, username: String, date: Date, body: String, indention: Int, children: [FeedItem]) -> FeedItem {
        // Create a new feed item
        return FeedItem(style: .comment, id: id, username: username, date: date, title: nil, body: body, thumbnail: nil, children: children, indention: indention)
    
    }
    
    func getSelfWithChildrenRecursively(forceExpanded: Bool = false) -> [FeedItem] {
        if let children = self.children,
            isExpanded || forceExpanded {
            return [self] + children.flatMap { $0.getSelfWithChildrenRecursively() }
        }
        return [self]
    }
}

extension Array<FeedItem> {
    func recursiveFindItem(withId: UUID) -> FeedItem? {
        for item in self {
            if item.id == withId {
                return item
            }
            
            if let child = item.children?.recursiveFindItem(withId: withId) {
                return child
            }
        }
        
        return nil
    }
    
    /**
     * @param withId: id of object to find
     * @param mutation: callback for the mutation funciton
     * @returns true if item was found and mutated
     */
    @discardableResult
    mutating func recursiveFindAndMutateItem(withId id: UUID, mutation: (inout FeedItem) -> Void) -> Bool {
        for (i, item) in enumerated() {
            var mutableItem = item
            
            if item.id == id {
                mutation(&mutableItem)
                self[i] = mutableItem
                return true
            }
            
            else if var children = item.children {
                let didMutateChild = children.recursiveFindAndMutateItem(withId: id, mutation: mutation)
                
                if (didMutateChild) {
                    mutableItem.children = children
                    self[i] = mutableItem
                    return true
                }
            }
        }
        
        return false
    
    }
}
