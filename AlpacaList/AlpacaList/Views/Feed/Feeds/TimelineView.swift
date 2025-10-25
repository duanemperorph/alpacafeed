//
//  TimelineView.swift
//  AlpacaList
//
//  Timeline feed view (replaces PostsFeedView)
//

import SwiftUI

/// Timeline feed view for home, profile, or custom feeds
struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
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
                        navigationCoordinator.push(.thread(uri: tappedPost.uri))
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
                        navigationCoordinator.push(.thread(uri: uri))
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    navigationCoordinator.presentCompose()
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .onAppear {
            // Clear thread context when viewing timeline
            navigationCoordinator.currentThreadRootPost = nil
        }
    }
}

// MARK: - Previews

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimelineView(viewModel: TimelineViewModel.withMockData())
                .navigationTitle("Home")
        }
    }
}

