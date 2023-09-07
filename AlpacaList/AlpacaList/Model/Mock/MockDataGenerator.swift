//
//  MockDataGenerator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/29/23.
//

import Foundation

class MockDataGenerator {
    static func generateRandomPost(childLength: Int, depth: Int) -> FeedItem {
        let user = mockUsers.randomElement()!
        let title = mockTitles.randomElement()!
        let content = mockResponses.randomElement()!
        let children = generateChildren(maxLength: childLength, depth: depth)
        return FeedItem.createPost(id: UUID(), username: user, date: Date(), title: title, body: content, thumbnail: generateThumbnail(), children: children)
    }
    
    static func generatePosts(length: Int = 20, childLength: Int = 10, depth: Int = 3) -> [FeedItem] {
        var items: [FeedItem] = []
        
        for _ in 0..<length {
            // create an item and add to the items array
            items.append(generateRandomPost(childLength: childLength, depth: depth))
        }
        
        return items
    }
    
    static func generateRandomComment(maxLength: Int, depth: Int, indention: Int) -> FeedItem {
        let user = mockUsers.randomElement()!
        let content = mockResponses.randomElement()!
        let children = depth > 0 ? generateChildren(maxLength: maxLength, depth: depth - 1, indention: indention + 1) : []
        return FeedItem.createComment(id: UUID(), username: user, date: Date(), body: content, indention: indention, children: children)
    }
    
    static func generateChildren(maxLength: Int, depth: Int, indention: Int = 1) -> [FeedItem] {
        var items: [FeedItem] = []
        let length = Int.random(in: 0...maxLength)
        
        for _ in 0..<length {
            // create an item and add to the items array
            items.append(generateRandomComment(maxLength: maxLength, depth: depth, indention: indention))
        }
        
        return items
    }
    
    static func generateThumbnail() -> String? {
        // return null 50% of the time
        if Int.random(in: 0...1) == 0 {
            return nil
        }
        
        let randomIndex = Int.random(in: 1...8)
        return "alpaca\(randomIndex)"
    }
}
