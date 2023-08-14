//
//  CommentsFeedView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/6/23.
//

import SwiftUI

struct CommentsFeedView: View {
    let rootItem: FeedItem
    @State var isTopBarOpen = false
    
    var items: [FeedItem] {
        return rootItem.getSelfWithChildrenRecursively(forceExpanded: true)
    }
    
    var listDrag: some Gesture {
        DragGesture(coordinateSpace: .local).onChanged { data in
            if (isTopBarOpen && data.translation.height < 0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isTopBarOpen = false
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            FeedViewBackground()
            List(items) { item in
                FeedItemView(postItem: item)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5, leading: 10 + indentionForItem(item: item), bottom: 5, trailing: 10))
            }
            .padding(0)
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .gesture(listDrag)
            .safeAreaInset(edge: .top) {
                TopBarContainer(isOpen: $isTopBarOpen)
            }
        }
    }
    
    func indentionForItem(item: FeedItem) -> Double {
        return Double(item.indention ?? 0) * 10
    }
}

struct CommentsFeedView_Previews: PreviewProvider {
    static let mockFeedItems = MockDataGenerator.generatePosts()
    
    static var previews: some View {
        CommentsFeedView(rootItem: mockFeedItems.randomElement()!)
    }
}
