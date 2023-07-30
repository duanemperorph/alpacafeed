//
//  MockDataGenerator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/29/23.
//

import Foundation

class MockDataGenerator {

    static func generatePosts(length: Int = 20, childLength: Int = 5, depth: Int = 3) -> [PostItem] {
        var items: [PostItem] = []
        
        for _ in 0..<length {
            let user = mockUsers.randomElement()!
            let title = mockTitles.randomElement()!
            let content = mockResponses.randomElement()!
            let children = generateChildren(length: childLength, depth: depth)
            
            // create an item and add to the items array
            items.append(PostItem(thumbnail: generateThumbnail(), title: title, body: content, username: user, date: Date(), children: children))
        
        }
        
        return items
    }
    
    static func generateChildren(length: Int, depth: Int) -> [CommentItem] {
        var items: [CommentItem] = []
        
        for _ in 0..<length {
            let user = mockUsers.randomElement()!
            let content = mockResponses.randomElement()!
            let children = depth > 0 ? generateChildren(length: length, depth: depth - 1) : []
            
            // create an item and add to the items array
            items.append(CommentItem(text: content, username: user, date: Date(), children: children))
        
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
