//
//  FeedItemView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

// Swift view displaying a feed item
struct FeedItemView: View {
    let item: FeedItem
    let containerModel: CommentsViewModel?
    
    init(item: FeedItem, containerModel: CommentsViewModel? = nil) {
        self.item = item
        self.containerModel = containerModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = item.title {
                PostTitle(title: title)
            }
            
            PostUsername(username: item.username)
            
            if let thumbnail = item.thumbnail {
                PostThumbnail(thumbnail: thumbnail)
            } else if let body = item.body {
                PostBody(bodyText: body)
            }
            Spacer().frame(height: 15)
            switch item.style {
                case .post:
                    PostItemButtons()
                case .comment:
                CommentItemButtons(item: item, toggleExpanded: toggleExpanded)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
    
    func toggleExpanded() {
        print("toggle expanded")
        containerModel?.toggleExpandedForCommentWithId(id: item.id)
    }
}

//struct FeedViewItem_Previews: PreviewProvider {
//    static let mockFeedItems = MockDataGenerator.generatePosts()
//
//    static var previews: some View {
//        ZStack {
//            PostFeedView(items: mockFeedItems)
//        }
//    }
//}
