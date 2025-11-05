//
//  ExternalLinkEmbed.swift
//  AlpacaList
//
//  External link preview embed component
//

import SwiftUI

/// Displays external link with preview card
struct ExternalLinkEmbed: View {
    let external: Embed.ExternalEmbed
    
    var body: some View {
        Button(action: {
            // TODO: Open link in browser
            if let url = URL(string: external.uri) {
                #if os(iOS)
                UIApplication.shared.open(url)
                #endif
            }
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(external.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Description
                    Text(external.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // URL
                    Text(extractDomain(from: external.uri))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Thumbnail
                if let thumb = external.thumb {
                    Image(thumb)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
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
    
    private func extractDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return urlString
        }
        return host
    }
}

