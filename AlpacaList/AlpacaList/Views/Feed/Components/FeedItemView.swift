//
//  FeedItemView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

// Swift view displaying a feed item
struct FeedItemView: View {
    let postItem: FeedItem
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = postItem.title {
                PostTitle(title: title)
            }
            
            PostUsername(username: postItem.username)
            
            if let thumbnail = postItem.thumbnail {
                PostThumbnail(thumbnail: thumbnail)
            } else if let body = postItem.body {
                PostBody(bodyText: body)
            }
            Spacer().frame(height: 15)
            switch postItem.style {
                case .post:
                    PostItemButtons()
                case .comment:
                    CommentItemButtons()
            }
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
