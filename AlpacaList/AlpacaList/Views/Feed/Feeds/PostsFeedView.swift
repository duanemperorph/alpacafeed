//
//  ContentView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

struct PostsFeedView: View {
    let model: PostsListViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var topBarController: TopBarController
    
    var listDrag: some Gesture {
        DragGesture(coordinateSpace: .local).onChanged { data in
            if (topBarController.isExpanded && data.translation.height < 0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    topBarController.collapse()
                }
            }
        }
    }
    
    var body: some View {
        FeedListView(listItems: model.posts, listAccessibilityIdentifier: "feed_list") { item in
            FeedItemView(model: item, onClick: { clickedItem in
                navigationCoordinator.push(.postDetails(postItem: clickedItem))
            })
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static let mockFeedItems = MockDataGenerator.generatePosts()
    
    static var previews: some View {
        RootPreviews()
        RootPreviews()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewDisplayName("iPad Pro 11\"")
    }
}
