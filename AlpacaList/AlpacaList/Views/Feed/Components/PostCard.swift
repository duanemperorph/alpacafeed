//
//  PostCard.swift
//  AlpacaList
//
//  Unified post card component (replaces FeedItemView)
//

import SwiftUI

/// Unified post card for timeline and thread views
struct PostCard: View {
    let post: Post
    let isMainPost: Bool
    let showReplyContext: Bool
    
    let onPostTap: ((Post) -> Void)?
    let onLike: ((String) -> Void)?
    let onRepost: ((String) -> Void)?
    let onReply: ((String) -> Void)?
    let onQuotePostTap: ((String) -> Void)?
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(
        post: Post,
        isMainPost: Bool = false,
        showReplyContext: Bool = false,
        onPostTap: ((Post) -> Void)? = nil,
        onLike: ((String) -> Void)? = nil,
        onRepost: ((String) -> Void)? = nil,
        onReply: ((String) -> Void)? = nil,
        onQuotePostTap: ((String) -> Void)? = nil
    ) {
        self.post = post
        self.isMainPost = isMainPost
        self.showReplyContext = showReplyContext
        self.onPostTap = onPostTap
        self.onLike = onLike
        self.onRepost = onRepost
        self.onReply = onReply
        self.onQuotePostTap = onQuotePostTap
    }
    
    var body: some View {
        Button(action: {
            onPostTap?(post)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Author header
                AuthorHeader(
                    author: post.author,
                    createdAt: post.createdAt,
                    repostedBy: post.repostedBy
                )
                
                // Reply context indicator
                if showReplyContext && post.isReply {
                    HStack(spacing: 4) {
                        Image(systemName: "arrowshape.turn.up.left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Replying to a post")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Post text
                RichTextView(
                    text: post.text,
                    facets: post.facets
                )
                .font(isMainPost ? .body : .subheadline)
                
                // Embedded content
                if let embed = post.embed {
                    PostEmbed(embed: embed, onQuotePostTap: onQuotePostTap)
                }
                
                // Engagement bar
                if let onLike = onLike,
                   let onRepost = onRepost,
                   let onReply = onReply {
                    EngagementBar(
                        likeCount: post.likeCount,
                        repostCount: post.repostCount,
                        replyCount: post.replyCount,
                        quoteCount: post.quoteCount,
                        isLiked: post.isLiked,
                        isReposted: post.isReposted,
                        onLike: { onLike(post.uri) },
                        onRepost: { onRepost(post.uri) },
                        onReply: { onReply(post.uri) }
                    )
                } else {
                    // Read-only engagement counts
                    EngagementBarCompact(
                        likeCount: post.likeCount,
                        repostCount: post.repostCount,
                        replyCount: post.replyCount
                    )
                }
            }
            .padding(16)
            .background(
                isMainPost ? Color.blue.opacity(0.05) : Color.clear,
                in: RoundedRectangle(cornerRadius: 0)
            )
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isMainPost ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Post by \(post.author.displayNameOrHandle)")
    }
}

// MARK: - Compact Post Card (for thread context)

struct PostCardCompact: View {
    let post: Post
    let onPostTap: ((Post) -> Void)?
    
    var body: some View {
        Button(action: {
            onPostTap?(post)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                AuthorHeaderCompact(author: post.author, createdAt: post.createdAt)
                
                Text(post.text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

struct PostCard_Previews: PreviewProvider {
    static var previews: some View {
        let author = Author(
            did: "did:plc:alice123",
            handle: "alice.bsky.social",
            displayName: "Alice Anderson",
            avatar: "alpaca1"
        )
        
        let repostedBy = Author(
            did: "did:plc:bob456",
            handle: "bob.bsky.social",
            displayName: "Bob Builder"
        )
        
        ScrollView {
            VStack(spacing: 16) {
                // Simple text post
                PostCard(
                    post: Post.createTextPost(
                        author: author,
                        text: "Just discovered this amazing community! 🎉"
                    ),
                    onLike: { _ in },
                    onRepost: { _ in },
                    onReply: { _ in }
                )
                
                // Post with image
                PostCard(
                    post: Post.createImagePost(
                        author: author,
                        text: "Check out this adorable alpaca! 🦙",
                        images: [
                            Embed.ImageEmbed(
                                thumb: "alpaca1",
                                fullsize: "alpaca1",
                                alt: "An adorable alpaca",
                                aspectRatio: Embed.AspectRatio(width: 16, height: 9)
                            )
                        ]
                    ),
                    onLike: { _ in },
                    onRepost: { _ in },
                    onReply: { _ in }
                )
                
                // Post with repost attribution
                PostCard(
                    post: Post(
                        uri: "at://did:plc:alice123/app.bsky.feed.post/abc123",
                        cid: "bafyreiabc123",
                        author: author,
                        createdAt: Date().addingTimeInterval(-3600),
                        text: "This is an important message that everyone should see!",
                        likeCount: 42,
                        repostCount: 12,
                        replyCount: 5,
                        repostedBy: repostedBy
                    ),
                    onLike: { _ in },
                    onRepost: { _ in },
                    onReply: { _ in }
                )
                
                // Main post (highlighted)
                PostCard(
                    post: Post.createTextPost(
                        author: author,
                        text: "This is the main post in a thread. It should stand out from the rest."
                    ),
                    isMainPost: true,
                    onLike: { _ in },
                    onRepost: { _ in },
                    onReply: { _ in }
                )
                
                // Compact version
                PostCardCompact(
                    post: Post.createTextPost(
                        author: author,
                        text: "This is a compact version of a post card, useful for showing context in threads."
                    ),
                    onPostTap: { _ in }
                )
                
                // Post with active engagement
                PostCard(
                    post: Post(
                        uri: "at://did:plc:alice123/app.bsky.feed.post/def456",
                        cid: "bafyreidef456",
                        author: author,
                        createdAt: Date().addingTimeInterval(-7200),
                        text: "Already liked and reposted this one! 💙",
                        likeCount: 128,
                        repostCount: 34,
                        replyCount: 16,
                        isLiked: true,
                        isReposted: true
                    ),
                    onLike: { _ in },
                    onRepost: { _ in },
                    onReply: { _ in }
                )
            }
            .padding()
        }
    }
}

