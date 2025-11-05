//
//  PostEmbed.swift
//  AlpacaList
//
//  Embedded media and content for Bluesky posts
//

import SwiftUI
import AVKit

/// Renders embedded content (images, videos, links, quotes)
struct PostEmbed: View {
    let embed: Embed
    let onQuotePostTap: ((String) -> Void)?
    
    init(embed: Embed, onQuotePostTap: ((String) -> Void)? = nil) {
        self.embed = embed
        self.onQuotePostTap = onQuotePostTap
    }
    
    var body: some View {
        Group {
            switch embed {
            case .images(let images):
                ImagesEmbed(images: images)
                
            case .video(let video):
                VideoEmbed(video: video)
                
            case .external(let external):
                ExternalLinkEmbed(external: external)
                
            case .record(let record):
                QuotePostEmbed(record: record, onTap: onQuotePostTap)
                
            case .recordWithMedia(let record, let media):
                VStack(spacing: 12) {
                    // Show media first
                    switch media {
                    case .images(let images):
                        ImagesEmbed(images: images)
                    case .video(let video):
                        VideoEmbed(video: video)
                    }
                    
                    // Then show quoted post
                    QuotePostEmbed(record: record, onTap: onQuotePostTap)
                }
            }
        }
    }
}

// MARK: - Images Embed

struct ImagesEmbed: View {
    let images: [Embed.ImageEmbed]
    
    var body: some View {
        Group {
            if images.count == 1 {
                // Single image - full width
                if let image = images.first {
                    SingleImageView(image: image)
                }
            } else if images.count == 2 {
                // Two images - side by side
                HStack(spacing: 4) {
                    ForEach(images) { image in
                        SingleImageView(image: image)
                    }
                }
            } else if images.count == 3 {
                // Three images - one large, two small
                HStack(spacing: 4) {
                    SingleImageView(image: images[0])
                    VStack(spacing: 4) {
                        SingleImageView(image: images[1])
                        SingleImageView(image: images[2])
                    }
                }
            } else if images.count == 4 {
                // Four images - 2x2 grid
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        SingleImageView(image: images[0])
                        SingleImageView(image: images[1])
                    }
                    HStack(spacing: 4) {
                        SingleImageView(image: images[2])
                        SingleImageView(image: images[3])
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SingleImageView: View {
    let image: Embed.ImageEmbed
    
    var body: some View {
        // Use fullsize as image name for now
        Image(image.fullsize)
            .resizable()
            .scaledToFill()
            .frame(maxHeight: 300)
            .clipped()
            .accessibilityLabel(image.alt ?? "Image")
    }
}

// MARK: - Video Embed

struct VideoEmbed: View {
    let video: Embed.VideoEmbed
    
    var body: some View {
        InlineVideoPlayer(
            videoUrl: video.playlist,
            thumbnail: video.thumbnail,
            altText: video.alt,
            aspectRatio: video.aspectRatio
        )
    }
}

// MARK: - Inline Video Player

struct InlineVideoPlayer: View {
    let videoUrl: String
    let thumbnail: String?
    let altText: String?
    let aspectRatio: Embed.AspectRatio?
    
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showThumbnail = true
    @State private var isLoading = false
    @State private var statusObserver: NSKeyValueObservation?
    
    var body: some View {
        ZStack {
            // Video player
            if let player = player, !showThumbnail {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .disabled(true) // Disable VideoPlayer's built-in controls
            } else {
                // Thumbnail
                if let thumbnail = thumbnail {
                    Image(thumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxHeight: 300)
                }
            }
            
            // Loading indicator
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .shadow(radius: 5)
            }
            
            // Play/Pause button overlay
            if !isLoading {
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                }
                .opacity(showThumbnail || !isPlaying ? 1 : 0.3)
                .animation(.easeInOut(duration: 0.2), value: isPlaying)
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityLabel(altText ?? "Video")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isPlaying ? "Pause video" : "Play video")
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: videoUrl) else { return }
        print("setup player with url: \(url)")
        player = AVPlayer(url: url)
        
        // Observe when video finishes playing
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [self] _ in
            isPlaying = false
            showThumbnail = true
            player?.seek(to: .zero)
        }
        
        // Observe player status using KVO
        if let item = player?.currentItem {
            statusObserver = item.observe(\.status, options: [.new, .initial]) { item, change in
                DispatchQueue.main.async {
                    if item.status == .readyToPlay {
                        isLoading = false
                        print("Player is ready to play")
                    } else if item.status == .failed {
                        isLoading = false
                        print("Player failed: \(item.error?.localizedDescription ?? "unknown error")")
                    }
                }
            }
        }
    }
    
    private func togglePlayback() {
        guard let player = player else { return }
        
        if isPlaying {
            // Pause
            player.pause()
            isPlaying = false
        } else {
            // Play
            if showThumbnail {
                isLoading = true
                showThumbnail = false
                
                // Small delay to ensure player is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    player.play()
                    isPlaying = true
                    isLoading = false
                }
            } else {
                player.play()
                isPlaying = true
            }
        }
    }
    
    private func cleanupPlayer() {
        statusObserver?.invalidate()
        statusObserver = nil
        player?.pause()
        player = nil
        isPlaying = false
        showThumbnail = true
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - External Link Embed

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

// MARK: - Quote Post Embed

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

// MARK: - Previews

struct PostEmbed_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Single image
                PostEmbed(embed: .images([
                    Embed.ImageEmbed(
                        thumb: "alpaca1",
                        fullsize: "alpaca1",
                        alt: "An adorable alpaca",
                        aspectRatio: Embed.AspectRatio(width: 16, height: 9)
                    )
                ]))
                
                // Multiple images
                PostEmbed(embed: .images([
                    Embed.ImageEmbed(thumb: "alpaca1", fullsize: "alpaca1", alt: nil, aspectRatio: nil),
                    Embed.ImageEmbed(thumb: "alpaca2", fullsize: "alpaca2", alt: nil, aspectRatio: nil),
                    Embed.ImageEmbed(thumb: "alpaca3", fullsize: "alpaca3", alt: nil, aspectRatio: nil),
                    Embed.ImageEmbed(thumb: "alpaca4", fullsize: "alpaca4", alt: nil, aspectRatio: nil)
                ]))
                
                // Video
                PostEmbed(embed: .video(
                    Embed.VideoEmbed(
                        thumbnail: "alpaca5",
                        playlist: "https://example.com/video.m3u8",
                        alt: "Video of alpacas",
                        aspectRatio: nil
                    )
                ))
                
                // External link
                PostEmbed(embed: .external(
                    Embed.ExternalEmbed(
                        uri: "https://example.com/alpacas",
                        title: "The Ultimate Guide to Alpacas",
                        description: "Everything you need to know about these amazing animals",
                        thumb: "alpaca6"
                    )
                ))
                
                // Quote post
                PostEmbed(embed: .record(
                    Embed.RecordEmbed(
                        uri: "at://did:plc:example/app.bsky.feed.post/abc123",
                        cid: "bafyreiabc123"
                    )
                ))
            }
            .padding()
        }
    }
}

