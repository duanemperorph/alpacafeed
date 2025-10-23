//
//  AuthorHeader.swift
//  AlpacaList
//
//  Author header component for Bluesky posts
//

import SwiftUI

/// Header showing author info (avatar, display name, handle, timestamp)
struct AuthorHeader: View {
    let author: Author
    let createdAt: Date
    let repostedBy: Author?
    
    init(author: Author, createdAt: Date, repostedBy: Author? = nil) {
        self.author = author
        self.createdAt = createdAt
        self.repostedBy = repostedBy
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Repost indicator (if applicable)
            if let repostedBy = repostedBy {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(repostedBy.displayNameOrHandle) reposted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Main author info
            HStack(spacing: 12) {
                // Avatar
                if let avatarName = author.avatar {
                    Image(avatarName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    // Placeholder avatar
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                }
                
                // Name, handle, timestamp
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        // Display name
                        if let displayName = author.displayName {
                            Text(displayName)
                                .font(.headline)
                                .lineLimit(1)
                        }
                        
                        // Timestamp
                        Text("·")
                            .foregroundColor(.secondary)
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Handle
                    Text("@\(author.handle)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // More button
                Button(action: {
                    // TODO: Show post menu
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    private var formattedDate: String {
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)
        
        // Less than 1 minute
        if interval < 60 {
            return "now"
        }
        
        // Less than 1 hour
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        }
        
        // Less than 24 hours
        if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        }
        
        // Less than 7 days
        if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d"
        }
        
        // More than 7 days - show actual date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: createdAt)
    }
}

// MARK: - Compact Version (for thread context)

struct AuthorHeaderCompact: View {
    let author: Author
    let createdAt: Date
    
    var body: some View {
        HStack(spacing: 8) {
            // Smaller avatar
            if let avatarName = author.avatar {
                Image(avatarName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    )
            }
            
            // Name and handle inline
            HStack(spacing: 4) {
                if let displayName = author.displayName {
                    Text(displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
                
                Text("@\(author.handle)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text("·")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var formattedDate: String {
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)
        
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        if interval < 604800 { return "\(Int(interval / 86400))d" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: createdAt)
    }
}

// MARK: - Previews

struct AuthorHeader_Previews: PreviewProvider {
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
        
        VStack(spacing: 20) {
            AuthorHeader(author: author, createdAt: Date().addingTimeInterval(-3600))
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            AuthorHeader(author: author, createdAt: Date().addingTimeInterval(-3600), repostedBy: repostedBy)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            AuthorHeaderCompact(author: author, createdAt: Date().addingTimeInterval(-7200))
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

