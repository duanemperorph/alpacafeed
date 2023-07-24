//
//  FeedItemView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI


// Swift view displaying a feed item
struct FeedItemView: View {
    let feedItem: FeedItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(feedItem.title)
                .font(.headline)
            
            if let thumbnail = feedItem.thumbnail {
                // Display thumbnail
                Image(thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else {
                // Display body
                Text(feedItem.body)
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
            }
            
            Text(feedItem.username)
                .frame(maxWidth: .infinity,
                        alignment: .leading)
            
            FeedItemButtons()
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct FeedViewItem_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            FeedView(feedItems: exampleFeedItems)
        }
    }
}
