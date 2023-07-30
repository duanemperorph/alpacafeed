//
//  PostItemView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI


// Swift view displaying a feed item
struct PostItemView: View {
    let postItem: PostItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(postItem.title)
                .font(.headline)
            
            if let thumbnail = postItem.thumbnail {
                // Display thumbnail
                Image(thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else {
                // Display body
                Text(postItem.body)
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
            }
            
            Text(postItem.username)
                .frame(maxWidth: .infinity,
                        alignment: .leading)
            
            PostItemButtons()
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct FeedViewItem_Previews: PreviewProvider {
    static let mockPostItems = MockDataGenerator.generatePosts()
    
    static var previews: some View {
        ZStack {
            FeedView(postItems: mockPostItems)
        }
    }
}
