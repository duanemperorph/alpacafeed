//
//  EmbedPreview.swift
//  AlpacaList
//
//  Preview component for displaying pending embeds in compose view
//

import SwiftUI

// MARK: - Pending Embed Types

/// Represents a single pending image that hasn't been uploaded yet
struct PendingImage: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    var altText: String
    
    init(image: UIImage, altText: String = "") {
        self.id = UUID()
        self.image = image
        self.altText = altText
    }
}

/// Represents a pending embed that hasn't been uploaded yet
/// Note: Bluesky allows only ONE embed type per post (except quote+media)
enum PendingEmbed: Equatable {
    case images([PendingImage])  // Up to 4 images
    case video(thumbnail: UIImage?, duration: Double)
    case external(url: URL, title: String?, description: String?, thumbnail: UIImage?)
    case record(uri: String, cid: String)  // Quote post
    case recordWithImages(uri: String, cid: String, images: [PendingImage])  // Quote + images
    
    var isQuotePost: Bool {
        switch self {
        case .record, .recordWithImages: return true
        default: return false
        }
    }
    
    var hasImages: Bool {
        switch self {
        case .images, .recordWithImages: return true
        default: return false
        }
    }
    
    var imageCount: Int {
        switch self {
        case .images(let images): return images.count
        case .recordWithImages(_, _, let images): return images.count
        default: return 0
        }
    }
}

// MARK: - Embed Preview Component

struct EmbedPreview: View {
    let embed: PendingEmbed
    let maxImages: Int
    let onRemoveEmbed: () -> Void
    let onRemoveImage: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch embed {
            case .images(let images):
                imagePreviewGrid(images: images)
                
            case .video(let thumbnail, let duration):
                videoPreview(thumbnail: thumbnail, duration: duration)
                
            case .external(let url, let title, let description, let thumbnail):
                externalLinkPreview(url: url, title: title, description: description, thumbnail: thumbnail)
                
            case .record(let uri, _):
                quotePostPreview(uri: uri, images: nil)
                
            case .recordWithImages(let uri, _, let images):
                quotePostPreview(uri: uri, images: images)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Image Preview
    
    private func imagePreviewGrid(images: [PendingImage]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, pendingImage in
                        imagePreviewCard(pendingImage: pendingImage, index: index)
                    }
                }
                .padding(.horizontal)
            }
            
            // Image count indicator
            HStack {
                Image(systemName: "photo.stack")
                    .foregroundColor(.secondary)
                Text("\(images.count) of \(maxImages) images")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }
    
    private func imagePreviewCard(pendingImage: PendingImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: pendingImage.image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Remove button
            Button {
                onRemoveImage(index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 24, height: 24)
                    )
            }
            .padding(6)
        }
        .frame(width: 120, height: 120)
    }
    
    // MARK: - Video Preview
    
    private func videoPreview(thumbnail: UIImage?, duration: Double) -> some View {
        HStack(spacing: 12) {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "video")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading) {
                Text("Video")
                    .font(.headline)
                Text(String(format: "%.1f seconds", duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                onRemoveEmbed()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    // MARK: - External Link Preview
    
    private func externalLinkPreview(url: URL, title: String?, description: String?, thumbnail: UIImage?) -> some View {
        HStack(spacing: 12) {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "link")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let title = title {
                    Text(title)
                        .font(.headline)
                        .lineLimit(2)
                }
                if let description = description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Text(url.absoluteString)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                onRemoveEmbed()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    // MARK: - Quote Post Preview
    
    private func quotePostPreview(uri: String, images: [PendingImage]?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.bubble")
                    .foregroundColor(.secondary)
                Text("Quote Post")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    onRemoveEmbed()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Text(uri)
                .font(.caption)
                .foregroundColor(.blue)
                .lineLimit(1)
            
            // Show images if this is a recordWithImages case
            if let images = images, !images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, pendingImage in
                            Image(uiImage: pendingImage.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview

struct EmbedPreview_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Images embed preview
            if let image = UIImage(named: "alpaca1") {
                EmbedPreview(
                    embed: .images([
                        PendingImage(image: image, altText: "Test image 1"),
                        PendingImage(image: image, altText: "Test image 2")
                    ]),
                    maxImages: 4,
                    onRemoveEmbed: {},
                    onRemoveImage: { _ in }
                )
            }
            
            // Video embed preview
            EmbedPreview(
                embed: .video(thumbnail: nil, duration: 45.5),
                maxImages: 4,
                onRemoveEmbed: {},
                onRemoveImage: { _ in }
            )
            
            // External link preview
            EmbedPreview(
                embed: .external(
                    url: URL(string: "https://example.com")!,
                    title: "Example Website",
                    description: "This is an example link preview",
                    thumbnail: nil
                ),
                maxImages: 4,
                onRemoveEmbed: {},
                onRemoveImage: { _ in }
            )
            
            // Quote post preview
            EmbedPreview(
                embed: .record(uri: "at://did:plc:123/app.bsky.feed.post/abc", cid: "bafyreiabc"),
                maxImages: 4,
                onRemoveEmbed: {},
                onRemoveImage: { _ in }
            )
        }
        .padding()
    }
}

