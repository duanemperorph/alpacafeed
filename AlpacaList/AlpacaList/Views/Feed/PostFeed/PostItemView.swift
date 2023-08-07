//
//  FeedItemView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI


// Swift view displaying a feed item
struct PostItemView: View {
    let postItem: FeedItem
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = postItem.title {
                Text(title)
                    .font(.headline)
            }
            
            Text("@\(postItem.username)")
                .frame(maxWidth: .infinity,
                        alignment: .leading)
            
            if let thumbnail = postItem.thumbnail {
                // Display thumbnail
                Image(thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else if let body = postItem.body {
                // Display body
                Text(body)
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
            }
            Spacer().frame(height: 15)
            PostItemButtons()
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct FeedViewItem_Previews: PreviewProvider {
    static let mockFeedItems = MockDataGenerator.generatePosts()
    
    static var previews: some View {
        ZStack {
            PostFeedView(postItems: mockFeedItems)
        }
    }
}
