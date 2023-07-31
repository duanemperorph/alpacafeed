//
//  AlpacaListApp.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

@main
struct AlpacaListApp: App {
    let mockFeedItems = MockDataGenerator.generatePosts()
    
    var body: some Scene {
        WindowGroup {
            FeedView(postItems: mockFeedItems)
        }
    }
}
