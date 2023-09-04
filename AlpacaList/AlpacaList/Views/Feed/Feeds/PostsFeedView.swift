//
//  ContentView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

struct PostsFeedView: View {
    @State var model: PostsListViewModel
    @State var isTopBarOpen = false
    
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
            
            List(model.posts) { post in
                NavigationLink(
                    value: NavigationDestination.postDetails(postItem: post.feedItem),
                    label: {
                        FeedItemView(model: post)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    })
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
}

struct FeedView_Previews: PreviewProvider {
    static let mockFeedItems = MockDataGenerator.generatePosts()
    
    static var previews: some View {
        let model = PostsListViewModel(rootPosts: mockFeedItems)
       PostsFeedView(model: model)
    }
}
