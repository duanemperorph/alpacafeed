//
//  TimelineView.swift
//  AlpacaList
//
//  Timeline feed view (replaces PostsFeedView)
//

import SwiftUI

/// Timeline feed view for home, profile, or custom feeds
struct TimelineView: View {
    /// Task ID that triggers re-fetch when ViewModel or account changes
    private struct FetchTaskID: Equatable {
        let viewModelID: ObjectIdentifier
        let accountDID: String?
        
        init(viewModel: TimelineViewModel, accountDID: String?) {
            self.viewModelID = ObjectIdentifier(viewModel)
            self.accountDID = accountDID
        }
    }
    
    @Bindable var viewModel: TimelineViewModel
    @Environment(NavigationCoordinator.self) private var navigationCoordinator
    @Environment(AppState.self) private var appState
    
    var body: some View {
        let _ = print("[TimelineView] body evaluated, posts count: \(viewModel.posts.count)")
        
        PostListView(
            items: viewModel.posts,
            isLoading: viewModel.isLoading,
            isLoadingMore: viewModel.isLoadingMore,
            spacing: 0,
            listAccessibilityIdentifier: "timeline_list",
            onRefresh: {
                await viewModel.refresh()
            },
            onLoadMore: {
                viewModel.loadMore()
            },
            content: { post in
                PostCard(
                    post: post,
                    onPostTap: { tappedPost in
                        navigationCoordinator.push(.thread(post: tappedPost))
                    },
                    onLike: { uri in
                        viewModel.likePost(uri: uri)
                    },
                    onRepost: { uri in
                        viewModel.repost(uri: uri)
                    },
                    onReply: { uri in
                        // Find the post being replied to
                        if let post = viewModel.posts.first(where: { $0.uri == uri }) {
                            navigationCoordinator.presentCompose(replyTo: post)
                        }
                    },
                    onQuotePostTap: { uri in
                        // Find the quoted post to navigate with full context
                        if let quotedPost = viewModel.posts.first(where: { $0.uri == uri }) {
                            navigationCoordinator.push(.thread(post: quotedPost))
                        }
                    }
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Divider()
                    .padding(.horizontal)
            },
            emptyStateView: {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No posts yet")
                        .font(.headline)
                    
                    Text("Pull to refresh or check back later")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            },
            loadingView: {
                ProgressView("Loading timeline...")
            }
        )
        .task(id: FetchTaskID(viewModel: viewModel, accountDID: appState.activeAccountDID)) {
            // Fetch timeline when ViewModel changes (new feed) or account changes
            // Coordinator guarantees we're only shown when session is restored and authenticated
            viewModel.fetchTimeline()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    navigationCoordinator.presentCompose()
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        // No manual state syncing needed - coordinator reads semantic state from navigation stack!
    }
}

// MARK: - Previews

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let viewModel = appState.viewModelFactory.makeTimelineViewModel(feedType: .home)
        
        NavigationView {
            TimelineView(viewModel: viewModel)
                .navigationTitle("Home")
                .environment(appState)
                .environment(appState.navigationCoordinator)
        }
    }
}

