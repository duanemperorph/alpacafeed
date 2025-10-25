//
//  ThreadView.swift
//  AlpacaList
//
//  Thread view (replaces CommentsFeedView)
//

import SwiftUI

/// Thread/conversation view for viewing a post and its replies
struct ThreadView: View {
    @ObservedObject var viewModel: ThreadViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        PostListView(
            items: viewModel.replies,
            isLoading: viewModel.isLoading,
            isLoadingMore: viewModel.isLoadingMoreReplies,
            spacing: 0,
            listAccessibilityIdentifier: "thread_list",
            onRefresh: {
                await viewModel.refresh()
            },
            onLoadMore: {
                viewModel.fetchMoreReplies()
            },
            headerContent: {
                // Parent context (if this is a reply)
                if !viewModel.parentPosts.isEmpty {
                    ForEach(viewModel.parentPosts) { parentPost in
                        VStack(spacing: 0) {
                            PostCardCompact(
                                post: parentPost,
                                onPostTap: { tappedPost in
                                    navigationCoordinator.push(.thread(uri: tappedPost.uri))
                                }
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            
                            // Thread line
                            threadLine
                        }
                    }
                }
                
                // Main post (highlighted)
                if let rootPost = viewModel.rootPost {
                    PostCard(
                        post: rootPost,
                        isMainPost: true,
                        showReplyContext: false,
                        onPostTap: nil, // Already viewing this post
                        onLike: { uri in
                            viewModel.likePost(uri: uri)
                        },
                        onRepost: { uri in
                            viewModel.repost(uri: uri)
                        },
                        onReply: { uri in
                            navigationCoordinator.presentCompose(replyTo: viewModel.rootPost)
                        },
                        onQuotePostTap: { uri in
                            // TODO: Navigate to quoted post
                            print("Quoted post: \(uri)")
                        }
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Divider before replies
                    if !viewModel.replies.isEmpty {
                        Divider()
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        
                        // Replies header
                        HStack {
                            Text("Replies")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
            },
            content: { reply in
                PostCard(
                    post: reply,
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
                        if let post = viewModel.replies.first(where: { $0.uri == uri }) {
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
            loadingView: {
                ProgressView("Loading thread...")
            }
        )
        .onAppear {
            if viewModel.rootPost == nil {
                viewModel.fetchThread()
            }
            // Set current thread context for context-aware compose
            navigationCoordinator.currentThreadRootPost = viewModel.rootPost
        }
        .onDisappear {
            // Clear thread context when leaving thread view
            navigationCoordinator.currentThreadRootPost = nil
        }
    }
    
    private var threadLine: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 2, height: 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 32) // Align with avatar
    }
}

// MARK: - Previews

struct ThreadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ThreadView(viewModel: ThreadViewModel.withMockData())
                .navigationTitle("Thread")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

