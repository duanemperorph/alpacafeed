//
//  PostEmbed.swift
//  AlpacaList
//
//  Embedded media and content for Bluesky posts
//

import SwiftUI

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

