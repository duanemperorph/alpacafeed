//
//  FeedItemView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

// Swift view displaying a feed item
struct FeedItemView: View {
    @ObservedObject var model: FeedItemViewModel
    
    init(model: FeedItemViewModel) {
        self.model = model
    }
    
    var body: some View {
        let item = model.feedItem
        
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
            switch model.style {
                case .post:
                    PostItemButtons()
                case .comment:
                CommentItemButtons(model: model, toggleExpanded: toggleExpanded)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
    
    func toggleExpanded() {
        print("toggle expanded")
        model.isExpanded.toggle()
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
