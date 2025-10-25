//
//  ComposeViewModel.swift
//  AlpacaList
//
//  View model for post composition (new posts and replies)
//

import Foundation
import SwiftUI
import PhotosUI

/// View model for composing new posts and replies
class ComposeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var postText: String = ""
    @Published var currentEmbed: PendingEmbed? = nil
    @Published var isPosting: Bool = false
    @Published var postError: Error? = nil
    
    // MARK: - Properties
    
    let replyTo: Post?
    
    // MARK: - Constants
    
    let characterLimit = 300
    let maxImages = 4
    
    // MARK: - Computed Properties
    
    var characterCount: Int {
        postText.count
    }
    
    var isOverLimit: Bool {
        characterCount > characterLimit
    }
    
    var canPost: Bool {
        let hasText = !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasEmbed = currentEmbed != nil
        return (hasText || hasEmbed) && !isOverLimit && !isPosting
    }
    
    var canAddImages: Bool {
        guard let embed = currentEmbed else { return true }
        return embed.hasImages && embed.imageCount < maxImages
    }
    
    var imageEmbedCount: Int {
        currentEmbed?.imageCount ?? 0
    }
    
    var hasQuotePost: Bool {
        currentEmbed?.isQuotePost ?? false
    }
    
    var hasImages: Bool {
        currentEmbed?.hasImages ?? false
    }
    
    var placeholderText: String {
        if let replyTo = replyTo {
            return "Reply to @\(replyTo.author.handle)..."
        } else {
            return "What's on your mind?"
        }
    }
    
    var hasDraft: Bool {
        !postText.isEmpty || currentEmbed != nil
    }
    
    // MARK: - Initialization
    
    init(replyTo: Post? = nil) {
        self.replyTo = replyTo
    }
    
    // MARK: - Actions
    
    /// Load images from PhotosPicker items
    func loadImages(from items: [PhotosPickerItem]) async {
        var newImages: [PendingImage] = []
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                newImages.append(PendingImage(image: image))
            }
        }
        
        await MainActor.run {
            // Add to existing images or create new embed
            if case .images(let existingImages) = currentEmbed {
                var updatedImages = existingImages
                updatedImages.append(contentsOf: newImages)
                currentEmbed = .images(updatedImages)
            } else {
                // Create new image embed
                currentEmbed = .images(newImages)
            }
        }
    }
    
    /// Remove a specific image at index
    func removeImage(at index: Int) {
        guard case .images(var images) = currentEmbed else { return }
        images.remove(at: index)
        
        if images.isEmpty {
            currentEmbed = nil
        } else {
            currentEmbed = .images(images)
        }
    }
    
    /// Remove the entire embed
    func removeEmbed() {
        currentEmbed = nil
    }
    
    /// Create and post the content
    func createPost() async throws {
        guard canPost else { return }
        
        isPosting = true
        defer { isPosting = false }
        
        // TODO: Implement actual post creation with Bluesky API
        print("Posting: \(postText)")
        if let replyTo = replyTo {
            print("Reply to: \(replyTo.uri)")
        }
        
        if let embed = currentEmbed {
            await logEmbedInfo(embed)
        }
        
        // Simulate API call
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Success - clear the form
        await MainActor.run {
            resetForm()
        }
    }
    
    /// Save the current post as a draft
    func saveDraft() {
        // TODO: Implement draft saving to UserDefaults or local storage
        print("Saving draft: \(postText)")
        if let embed = currentEmbed {
            print("Draft includes embed: \(embed)")
        }
    }
    
    /// Load a saved draft
    func loadDraft() {
        // TODO: Implement draft loading from UserDefaults or local storage
        print("Loading draft...")
    }
    
    // MARK: - Private Helpers
    
    private func resetForm() {
        postText = ""
        currentEmbed = nil
        postError = nil
    }
    
    private func logEmbedInfo(_ embed: PendingEmbed) async {
        switch embed {
        case .images(let images):
            print("With \(images.count) images")
            // TODO: Upload images and create Embed.images
            // let imageEmbeds = images.map { pendingImage in
            //     Embed.ImageEmbed(
            //         thumb: "uploaded_thumb_url",
            //         fullsize: "uploaded_fullsize_url",
            //         alt: pendingImage.altText,
            //         aspectRatio: Embed.AspectRatio(
            //             width: Int(pendingImage.image.size.width),
            //             height: Int(pendingImage.image.size.height)
            //         )
            //     )
            // }
            // embed = .images(imageEmbeds)
            
        case .video(_, let duration):
            print("With video (duration: \(duration)s)")
            // TODO: Upload video and create Embed.video
            
        case .external(let url, _, _, _):
            print("With external link: \(url)")
            // TODO: Create Embed.external
            
        case .record(let uri, _):
            print("Quote post: \(uri)")
            // TODO: Create Embed.record
            
        case .recordWithImages(let uri, _, let images):
            print("Quote post with \(images.count) images: \(uri)")
            // TODO: Create Embed.recordWithMedia
        }
    }
}

// MARK: - Future Enhancements

extension ComposeViewModel {
    /// Add a video embed
    func addVideo(thumbnail: UIImage?, duration: Double) {
        guard currentEmbed == nil else { return }
        currentEmbed = .video(thumbnail: thumbnail, duration: duration)
    }
    
    /// Add an external link embed
    func addExternalLink(url: URL, title: String?, description: String?, thumbnail: UIImage?) {
        guard currentEmbed == nil else { return }
        currentEmbed = .external(url: url, title: title, description: description, thumbnail: thumbnail)
    }
    
    /// Add a quote post embed
    func addQuotePost(uri: String, cid: String) {
        guard currentEmbed == nil else { return }
        currentEmbed = .record(uri: uri, cid: cid)
    }
    
    /// Add images to an existing quote post
    func addImagesToQuotePost(images: [PendingImage]) {
        guard case .record(let uri, let cid) = currentEmbed else { return }
        currentEmbed = .recordWithImages(uri: uri, cid: cid, images: images)
    }
}

