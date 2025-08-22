//
//  CommentsFeedView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/6/23.
//

import SwiftUI

struct CommentsFeedView: View {
    @ObservedObject var model: CommentsListViewModel
    
    var body: some View {
        let items = model.postWithComments
        
        FeedListView(listItems: items) { item in
            FeedItemView(model: item)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 5, leading: 10 + indentionForItem(item: item), bottom: 5, trailing: 10))
        }
    }
    
    func indentionForItem(item: FeedItemViewModel) -> Double {
        return Double(item.indention) * 20
    }
}

struct CommentsFeedView_Previews: PreviewProvider {
    static let mockFeedItems = MockDataGenerator.generatePosts()
    
    static var previews: some View {
        return RootPreviews()
    }
}
