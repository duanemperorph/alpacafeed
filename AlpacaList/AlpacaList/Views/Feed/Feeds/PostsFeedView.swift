//
//  ContentView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

struct PostsFeedView: View {
    @State var model: PostsListViewModel
    @EnvironmentObject var navigationRootController: NavigationRootController
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
        ZStack {
            FeedViewBackground()
            
            List(model.posts) { post in
                FeedItemView(model: post, onClick: { item in
                    navigationRootController.push(.postDetails(postItem: item))
                })
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            }
            .padding(0)
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .gesture(listDrag)
            .safeAreaInset(edge: .top) {
                Spacer().frame(width: .infinity,height: 80)
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static let mockFeedItems = MockDataGenerator.generatePosts()
    
    static var previews: some View {
        return RootPreviews()
    }
}
