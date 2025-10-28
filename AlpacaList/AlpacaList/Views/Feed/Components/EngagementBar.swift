//
//  EngagementBar.swift
//  AlpacaList
//
//  Engagement buttons for Bluesky posts (like, repost, reply)
//

import SwiftUI

/// Engagement bar with like, repost, reply, and share buttons
struct EngagementBar: View {
    let likeCount: Int
    let repostCount: Int
    let replyCount: Int
    let quoteCount: Int?
    
    let isLiked: Bool
    let isReposted: Bool
    
    let onLike: () -> Void
    let onRepost: () -> Void
    let onReply: () -> Void
    let onShare: (() -> Void)?
    
    init(
        likeCount: Int,
        repostCount: Int,
        replyCount: Int,
        quoteCount: Int? = nil,
        isLiked: Bool,
        isReposted: Bool,
        onLike: @escaping () -> Void,
        onRepost: @escaping () -> Void,
        onReply: @escaping () -> Void,
        onShare: (() -> Void)? = nil
    ) {
        self.likeCount = likeCount
        self.repostCount = repostCount
        self.replyCount = replyCount
        self.quoteCount = quoteCount
        self.isLiked = isLiked
        self.isReposted = isReposted
        self.onLike = onLike
        self.onRepost = onRepost
        self.onReply = onReply
        self.onShare = onShare
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Reply button
            EngagementButton(
                icon: "bubble.left",
                count: replyCount,
                isActive: false,
                action: onReply
            )
            
            Spacer()
            
            // Repost button
            EngagementButton(
                icon: "arrow.2.squarepath",
                count: repostCount,
                isActive: isReposted,
                activeColor: .green,
                action: onRepost
            )
            
            Spacer()
            
            // Like button
            EngagementButton(
                icon: isLiked ? "heart.fill" : "heart",
                count: likeCount,
                isActive: isLiked,
                activeColor: .red,
                action: onLike
            )
            
            // Share button
            if let onShare = onShare {
                Spacer()
                EngagementButton(
                    icon: "square.and.arrow.up",
                    count: nil,
                    isActive: false,
                    action: onShare
                )
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Engagement Button

struct EngagementButton: View {
    let icon: String
    let count: Int?
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void
    
    init(
        icon: String,
        count: Int?,
        isActive: Bool,
        activeColor: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.count = count
        self.isActive = isActive
        self.activeColor = activeColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isActive ? activeColor : .secondary)
                
                if let count = count, count > 0 {
                    Text(formatCount(count))
                        .font(.subheadline)
                        .foregroundColor(isActive ? activeColor : .secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func formatCount(_ count: Int) -> String {
        if count < 1000 {
            return "\(count)"
        } else if count < 1_000_000 {
            let k = Double(count) / 1000.0
            return String(format: "%.1fK", k)
        } else {
            let m = Double(count) / 1_000_000.0
            return String(format: "%.1fM", m)
        }
    }
}

// MARK: - Compact Version (for smaller contexts)

struct EngagementBarCompact: View {
    let likeCount: Int
    let repostCount: Int
    let replyCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Reply count
            HStack(spacing: 4) {
                Image(systemName: "bubble.left")
                    .font(.caption)
                if replyCount > 0 {
                    Text("\(replyCount)")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
            
            // Repost count
            HStack(spacing: 4) {
                Image(systemName: "arrow.2.squarepath")
                    .font(.caption)
                if repostCount > 0 {
                    Text("\(repostCount)")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
            
            // Like count
            HStack(spacing: 4) {
                Image(systemName: "heart")
                    .font(.caption)
                if likeCount > 0 {
                    Text("\(likeCount)")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Previews

struct EngagementBar_Previews: PreviewProvider {
    @State static var isLiked = false
    @State static var isReposted = false
    @State static var likeCount = 42
    @State static var repostCount = 12
    
    static var previews: some View {
        VStack(spacing: 30) {
            // Full engagement bar
            EngagementBar(
                likeCount: 42,
                repostCount: 12,
                replyCount: 8,
                quoteCount: 3,
                isLiked: false,
                isReposted: false,
                onLike: {},
                onRepost: {},
                onReply: {},
                onShare: {}
            )
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            // Active states
            EngagementBar(
                likeCount: 43,
                repostCount: 13,
                replyCount: 8,
                isLiked: true,
                isReposted: true,
                onLike: {},
                onRepost: {},
                onReply: {}
            )
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            // Large numbers
            EngagementBar(
                likeCount: 1234,
                repostCount: 567,
                replyCount: 89,
                isLiked: false,
                isReposted: false,
                onLike: {},
                onRepost: {},
                onReply: {}
            )
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            // Compact version
            EngagementBarCompact(
                likeCount: 42,
                repostCount: 12,
                replyCount: 8
            )
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

