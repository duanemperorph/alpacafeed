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
    let isExpanded: Bool?
    let onToggleExpanded: (() -> Void)?
    
    init(model: FeedItemViewModel, onClick: OnClick? = nil, isExpanded: Bool? = nil, onToggleExpanded: (() -> Void)? = nil) {
        self.model = model
        self.onClick = onClick
        self.isExpanded = isExpanded
        self.onToggleExpanded = onToggleExpanded
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
                    .frame(maxWidth: 350, maxHeight: 250)
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
                    CommentItemButtons(isExpanded: isExpanded ?? false, toggleExpanded: toggleExpanded)
                        .accessibilityIdentifier("comment_buttons_\(model.id.uuidString)")
                }
            }
            .padding(15)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("feed_cell_\(model.id.uuidString)")
    }
    
    func toggleExpanded() {
        if let onToggleExpanded = onToggleExpanded {
            onToggleExpanded()
        }
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
