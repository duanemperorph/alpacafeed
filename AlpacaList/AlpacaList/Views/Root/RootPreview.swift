//
//  Previews.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/6/23.
//

import SwiftUI

struct RootPreviews: View {
    let mockFeedItems: [FeedItem]
    let navigationCoordinator: NavigationCoordinator = NavigationCoordinator()
    let topBarController: TopBarController = TopBarController()
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("-uiTesting") {
            // Deterministic single post with nested comments for UI tests
            let c1b1 = FeedItem.createComment(id: UUID(), username: "u", date: Date(), body: "c1b1", indention: 2, children: [])
            let c1b = FeedItem.createComment(id: UUID(), username: "u", date: Date(), body: "c1b", indention: 1, children: [c1b1])
            let c1a = FeedItem.createComment(id: UUID(), username: "u", date: Date(), body: "c1a", indention: 1, children: [])
            let c1 = FeedItem.createComment(id: UUID(), username: "u", date: Date(), body: "c1", indention: 0, children: [c1a, c1b])
            let c2 = FeedItem.createComment(id: UUID(), username: "v", date: Date(), body: "c2", indention: 0, children: [])
            let post = FeedItem.createPost(id: UUID(), username: "p", date: Date(), title: "t", body: "b", thumbnail: nil, children: [c1, c2])
            self.mockFeedItems = [post]
        } else {
            self.mockFeedItems = MockDataGenerator.generatePosts()
        }
    }
    
    var body: some View {
        NavigationRootView()
            .environmentObject(navigationCoordinator)
            .environmentObject(topBarController)
    }
}

struct Previews_Previews: PreviewProvider {
    static var previews: some View {
        RootPreviews()
    }
}
