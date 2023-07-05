//
//  ContentView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

struct FeedView: View {
    @State var feedItems: [FeedItem] = []
    @State var isTopBarOpen = false
    
    var listDrag: some Gesture {
        DragGesture(coordinateSpace: .local).onChanged { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                isTopBarOpen = false
            }
        }
    }
    
    var topBarTap: some Gesture {
        TapGesture().onEnded { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                isTopBarOpen = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            List {
                ForEach(feedItems) { item in
                    FeedItemView(feedItem: item)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(PlainListStyle())
            .gesture(listDrag)
            .safeAreaInset(edge: .top) {
                let topBar = VStack() {
                    if (isTopBarOpen) {
                        TopBarExpanded()
                    }
                    else {
                        TopBarMinimized()
                            .gesture(topBarTap)
                    }
                }
                topBar.transition(.scale)
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(feedItems: exampleFeedItems)
    }
}
