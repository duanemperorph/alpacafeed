//
//  PostListView.swift
//  AlpacaList
//
//  Generic scrollable list view for posts with refresh, pagination, and loading states
//

import SwiftUI

struct PostListView<Item: Identifiable, Content: View, EmptyContent: View, LoadingContent: View, HeaderContent: View>: View {
    let items: [Item]
    let isLoading: Bool
    let isLoadingMore: Bool
    let spacing: CGFloat
    let showBackground: Bool
    let showTopBarInset: Bool
    let listAccessibilityIdentifier: String?
    
    let onRefresh: (() async -> Void)?
    let onLoadMore: (() -> Void)?
    
    @ViewBuilder var headerContent: () -> HeaderContent
    @ViewBuilder var content: (Item) -> Content
    @ViewBuilder var emptyStateView: () -> EmptyContent
    @ViewBuilder var loadingView: () -> LoadingContent
    
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var topBarController: TopBarController
    
    init(
        items: [Item],
        isLoading: Bool = false,
        isLoadingMore: Bool = false,
        spacing: CGFloat = 0,
        showBackground: Bool = true,
        showTopBarInset: Bool = false,
        listAccessibilityIdentifier: String? = nil,
        onRefresh: (() async -> Void)? = nil,
        onLoadMore: (() -> Void)? = nil,
        @ViewBuilder headerContent: @escaping () -> HeaderContent = { EmptyView() },
        @ViewBuilder content: @escaping (Item) -> Content,
        @ViewBuilder emptyStateView: @escaping () -> EmptyContent = { EmptyView() },
        @ViewBuilder loadingView: @escaping () -> LoadingContent = { 
            ProgressView("Loading...")
        }
    ) {
        self.items = items
        self.isLoading = isLoading
        self.isLoadingMore = isLoadingMore
        self.spacing = spacing
        self.showBackground = showBackground
        self.showTopBarInset = showTopBarInset
        self.listAccessibilityIdentifier = listAccessibilityIdentifier
        self.onRefresh = onRefresh
        self.onLoadMore = onLoadMore
        self.headerContent = headerContent
        self.content = content
        self.emptyStateView = emptyStateView
        self.loadingView = loadingView
        
//        let itemIds = items.map({i in i.id})
//        print("loaded items: \(itemIds)")
    }
    
    var listDrag: some Gesture {
        DragGesture(coordinateSpace: .local).onChanged { data in
            if showTopBarInset && topBarController.isExpanded && data.translation.height < 0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    topBarController.collapse()
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            if showBackground {
                FeedViewBackground()
            }
            
            ScrollView {
                LazyVStack(spacing: spacing) {
                    // Optional header content
                    headerContent()
                    
                    // Main items
                    ForEach(items) { item in
                        content(item)
                        
                        // Load more trigger at last item
                        if onLoadMore != nil, item.id == items.last?.id {
                            loadMoreView
                        }
                    }
                }
            }
            .padding(0)
            .simultaneousGesture(listDrag)
            .if(showTopBarInset) { view in
                view.safeAreaInset(edge: .top) {
                    Spacer().frame(height: topBarController.topBarInset)
                }
            }
            .if(onRefresh != nil) { view in
                view.refreshable {
                    await onRefresh?()
                }
            }
            .accessibilityIdentifier(listAccessibilityIdentifier ?? "")
            .overlay {
                if isLoading && items.isEmpty {
                    loadingView()
                }
            }
            .overlay {
                if items.isEmpty && !isLoading {
                    emptyStateView()
                }
            }
        }
    }
    
    @ViewBuilder
    private var loadMoreView: some View {
        if isLoadingMore {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding()
        } else {
            Color.clear
                .frame(height: 1)
                .onAppear {
                    onLoadMore?()
                }
        }
    }
}

// MARK: - View Extension for Conditional Modifiers

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

