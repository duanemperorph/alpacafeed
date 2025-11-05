//
//  ImagesEmbed.swift
//  AlpacaList
//
//  Image gallery embed component for posts
//

import SwiftUI

/// Displays one or multiple images in various layouts
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

/// Single image view component
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

