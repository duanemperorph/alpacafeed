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
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let onClick: OnClick?
    
    init(model: FeedItemViewModel, onClick: OnClick? = nil) {
        self.model = model
        self.onClick = onClick
    }
    
    @ViewBuilder func mainBodyCompact(_ item: FeedItem) -> some View {
        VStack(alignment: .leading) {
            if let title = item.title {
                PostTitle(title: title)
            }
            
            PostUsername(username: item.username)
            
            if let thumbnail = item.thumbnail {
                PostThumbnail(thumbnail: thumbnail)
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else if let body = item.body {
                PostBody(bodyText: body)
            }
        }
    }
    
    @ViewBuilder func mainBodyRegular(_ item: FeedItem) -> some View {
        HStack {
            if let thumbnail = item.thumbnail {
                PostThumbnail(thumbnail: thumbnail)
                    .frame(maxWidth: .infinity, maxHeight: 350)
            }
            VStack(alignment: .leading) {
                if let title = item.title {
                    PostTitle(title: title)
                }
                
                PostUsername(username: item.username)
                
                if let body = item.body {
                    PostBody(bodyText: body)
                }
            }
        }
    }
    
    var body: some View {
        let item = model.feedItem
        
        Button(action: {
            if let onClick = onClick {
                onClick(model.feedItem)
            }
        }) {
            VStack {
                if horizontalSizeClass == .compact {
                    mainBodyCompact(item)
                }
                else {
                    mainBodyRegular(item)
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
        RootPreviews()
        RootPreviews()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewDisplayName("iPad Pro 11\"")
            .previewInterfaceOrientation(.landscapeLeft)
        RootPreviews()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewDisplayName("iPad Pro 11\" - Port")
    }
}
