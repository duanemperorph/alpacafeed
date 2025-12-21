//
//  QuotePostEmbed.swift
//  AlpacaList
//
//  Quoted post embed component
//

import SwiftUI
import Kingfisher

/// Displays quoted post embed
struct QuotePostEmbed: View {
    let record: Embed.RecordEmbed
    let onTap: ((String) -> Void)?
    
    var body: some View {
        Button(action: {
            if record.state == .available {
                onTap?(record.uri)
            }
        }) {
            content
        }
        .buttonStyle(.plain)
        .disabled(record.state != .available)
    }
    
    @ViewBuilder
    private var content: some View {
        switch record.state {
        case .available:
            availableContent
        case .notFound:
            unavailableContent(message: "Post not found", icon: "questionmark.circle")
        case .blocked:
            unavailableContent(message: "Post from blocked user", icon: "nosign")
        }
    }
    
    private var availableContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Author header
            if let author = record.author {
                HStack(spacing: 8) {
                    // Avatar
                    KFImage(URL(string: author.avatar ?? ""))
                        .placeholder {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                )
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                    
                    // Name and handle
                    HStack(spacing: 4) {
                        if let displayName = author.displayName, !displayName.isEmpty {
                            Text(displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        
                        Text("@\(author.handle)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        if let indexedAt = record.indexedAt {
                            Text("·")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text(formattedDate(indexedAt))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            // Post text
            if let text = record.text, !text.isEmpty {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func unavailableContent(message: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        if interval < 604800 { return "\(Int(interval / 86400))d" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 16) {
        // Available quote post
        QuotePostEmbed(
            record: Embed.RecordEmbed(
                uri: "at://did:plc:test/app.bsky.feed.post/123",
                cid: "abc123",
                author: Author(
                    did: "did:plc:test",
                    handle: "alice.bsky.social",
                    displayName: "Alice"
                ),
                text: "This is a quoted post with some sample text that shows how the quote embed looks when properly rendered.",
                indexedAt: Date().addingTimeInterval(-3600),
                state: .available
            ),
            onTap: nil
        )
        
        // Not found
        QuotePostEmbed(
            record: Embed.RecordEmbed(
                uri: "",
                cid: "",
                state: .notFound
            ),
            onTap: nil
        )
        
        // Blocked
        QuotePostEmbed(
            record: Embed.RecordEmbed(
                uri: "",
                cid: "",
                state: .blocked
            ),
            onTap: nil
        )
    }
    .padding()
}
