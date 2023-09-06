//
//  FeedItemView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

// Swift view displaying a feed item
struct FeedItemView: View {
    typealias OnClick = (FeedItem) -> Void
    
    @ObservedObject var model: FeedItemViewModel
    
    let onClick: OnClick?
    
    init(model: FeedItemViewModel, onClick: OnClick? = nil) {
        self.model = model
        self.onClick = onClick
    }
    
    var body: some View {
        let item = model.feedItem
        
        Button(action: {
            if let onClick = onClick {
                onClick(model.feedItem)
            }
        }) {
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
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
    
    func toggleExpanded() {
        print("toggle expanded")
        model.isExpanded.toggle()
    }
}

struct FeedViewItem_Previews: PreviewProvider {
    static var previews: some View {
        return RootPreviews()
    }
}
