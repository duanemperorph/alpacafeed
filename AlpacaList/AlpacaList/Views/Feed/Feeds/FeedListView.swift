//
//  FeedListView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/22/25.
//

import SwiftUI

struct FeedListView<ItemContent: View>: View {
    let listItems: [FeedItemViewModel]
    @ViewBuilder var itemViewContent: (FeedItemViewModel) -> ItemContent
    
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var topBarController: TopBarController
    
    init(listItems: [FeedItemViewModel], itemViewContent: @escaping (FeedItemViewModel) -> ItemContent) {
        self.listItems = listItems
        self.itemViewContent = itemViewContent
    }
    
    var listDrag: some Gesture {
        DragGesture(coordinateSpace: .local).onChanged { data in
            if (topBarController.isExpanded && data.translation.height < 0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    topBarController.collapse()
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            FeedViewBackground()
            
            ScrollView {
                LazyVStack {
                    ForEach(listItems, content: itemViewContent)
                }
            }
            .padding(0)
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .gesture(listDrag)
            .safeAreaInset(edge: .top) {
                Spacer().frame(height: topBarController.topBarInset)
            }
        }
    }
}

//#Preview {
//    FeedListView()
//}
