//
//  VideoEmbed.swift
//  AlpacaList
//
//  Video embed component for posts
//

import SwiftUI
import AVKit

/// Displays video embed with inline player
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

/// Inline video player with custom controls
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

