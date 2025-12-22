//
//  PostOverflowMenu.swift
//  AlpacaList
//
//  Overflow menu for post actions (follow, copy link, etc.)
//

import SwiftUI

struct PostOverflowMenu: View {
    let post: Post
    let isOwnPost: Bool
    let onFollowToggle: ((Author) -> Void)?
    let onViewFeed: ((Author) -> Void)?
    let onDelete: ((String) -> Void)?
    
    var body: some View {
        Menu {
            // View Feed - always available
            if let onViewFeed = onViewFeed {
                Button {
                    onViewFeed(post.author)
                } label: {
                    Label("View @\(post.author.handle)'s Feed", systemImage: "person.crop.rectangle.stack")
                }
            }
            
            // Follow/Unfollow - only for other users' posts
            if !isOwnPost, let onFollowToggle = onFollowToggle {
                Button {
                    onFollowToggle(post.author)
                } label: {
                    if post.author.isFollowing {
                        Label("Unfollow @\(post.author.handle)", systemImage: "person.badge.minus")
                    } else {
                        Label("Follow @\(post.author.handle)", systemImage: "person.badge.plus")
                    }
                }
            }
            
            Divider()
            
            // Copy link
            Button {
                copyPostLink()
            } label: {
                Label("Copy Link", systemImage: "link")
            }
            
            // Delete - only for own posts
            if isOwnPost, let onDelete = onDelete {
                Divider()
                
                Button(role: .destructive) {
                    onDelete(post.uri)
                } label: {
                    Label("Delete Post", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
    }
    
    private func copyPostLink() {
        // Build the Bluesky URL from the post URI
        // Format: at://did:plc:xxx/app.bsky.feed.post/rkey -> https://bsky.app/profile/handle/post/rkey
        let components = post.uri.replacingOccurrences(of: "at://", with: "").split(separator: "/")
        guard components.count >= 3 else { return }
        
        let rkey = String(components[2])
        let url = "https://bsky.app/profile/\(post.author.handle)/post/\(rkey)"
        
        UIPasteboard.general.string = url
    }
}

