//
//  CommentsFeedView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/6/23.
//

import SwiftUI

struct CommentsFeedView: View {
    @ObservedObject var model: CommentsListViewModel
    @EnvironmentObject var navigationBarController: NavigationBarController
    
    var listDrag: some Gesture {
        DragGesture(coordinateSpace: .local).onChanged { data in
            if (navigationBarController.isExpanded && data.translation.height < 0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    navigationBarController.collapse()
                }
            }
        }
    }
    
    var body: some View {
        let items = model.postWithComments
        
        ZStack {
            FeedViewBackground()
            List(items) { item in
                FeedItemView(model: item)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 5, leading: 10 + indentionForItem(item: item), bottom: 5, trailing: 10))
            }
            .padding(0)
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .gesture(listDrag)
        }
    }
    
    func indentionForItem(item: FeedItemViewModel) -> Double {
        return Double(item.indention) * 20
    }
}

struct CommentsFeedView_Previews: PreviewProvider {
    static let model = CommentsListViewModel.withMockData()
    
    static var previews: some View {
        CommentsFeedView(model: model)
    }
}
