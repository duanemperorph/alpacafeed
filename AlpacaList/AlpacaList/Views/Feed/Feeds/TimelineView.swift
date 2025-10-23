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
    @State private var showingComposer = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.posts) { post in
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
                            showingComposer = true
                        },
                        onQuotePostTap: { uri in
                            navigationCoordinator.push(.thread(uri: uri))
                        }
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Load more trigger
                    if post.id == viewModel.posts.last?.id {
                        loadMoreView
                    }
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .overlay {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                ProgressView("Loading timeline...")
            }
        }
        .overlay {
            if viewModel.posts.isEmpty && !viewModel.isLoading {
                emptyStateView
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingComposer = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showingComposer) {
            // TODO: Compose view
            Text("Compose new post")
        }
    }
    
    private var loadMoreView: some View {
        Group {
            if viewModel.isLoadingMore {
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
                        viewModel.loadMore()
                    }
            }
        }
    }
    
    private var emptyStateView: some View {
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

