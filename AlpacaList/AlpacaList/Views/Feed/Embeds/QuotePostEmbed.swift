//
//  QuotePostEmbed.swift
//  AlpacaList
//
//  Quoted post embed component
//

import SwiftUI

/// Displays quoted post embed
struct QuotePostEmbed: View {
    let record: Embed.RecordEmbed
    let onTap: ((String) -> Void)?
    
    var body: some View {
        Button(action: {
            onTap?(record.uri)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // TODO: Fetch and display actual quoted post content
                // For now, show placeholder
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quoted Post")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("@user.bsky.social")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("This is a quoted post. Content would be fetched from the AT Protocol using the URI.")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(4)
                
                Text("URI: \(record.uri)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

