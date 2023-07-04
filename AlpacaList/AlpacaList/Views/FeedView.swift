//
//  ContentView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

struct FeedView: View {
    @State var feedItems: [FeedItem] = []
    
    var drag: some Gesture {
        DragGesture(coordinateSpace: .local)
            .onChanged { value in print("start dragging", value)}
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
            .gesture(drag)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            FeedView(feedItems: exampleFeedItems)
            VStack {
                TopBarMinimized()
                Spacer()
            }
        }
    }
}
