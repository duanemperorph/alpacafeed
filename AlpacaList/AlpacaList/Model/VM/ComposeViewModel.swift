//
//  ComposeViewModel.swift
//  AlpacaList
//
//  View model for post composition (new posts and replies)
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation

/// View model for composing new posts and replies
class ComposeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var postText: String = ""
    @Published var currentEmbed: PendingEmbed? = nil
    @Published var isPosting: Bool = false
    @Published var postError: Error? = nil
    @Published var isLoadingLink: Bool = false
    
    // UI presentation state
    @Published var showingDraftAlert: Bool = false
    @Published var showingImagePicker: Bool = false
    @Published var showingVideoPicker: Bool = false
    @Published var showingLinkInput: Bool = false
    
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
    
    var canAddVideo: Bool {
        // Can only add video if there's no embed, or if we already have a video
        guard let embed = currentEmbed else { return true }
        if case .video = embed {
            return false // Already have a video
        }
        return false // Has some other embed
    }
    
    var canAddLink: Bool {
        // Can only add link if there's no embed
        guard let embed = currentEmbed else { return true }
        if case .external = embed {
            return false // Already have a link
        }
        return false // Has some other embed
    }
    
    var imageEmbedCount: Int {
        currentEmbed?.imageCount ?? 0
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
        var pendingImages: [PendingImage] = []
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                pendingImages.append(PendingImage(image: image))
            }
        }
        
        let newImages = pendingImages
        
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
    
    /// Load video from PhotosPicker item
    func loadVideo(from item: PhotosPickerItem) async {
        guard canAddVideo else { return }
        
        do {
            // Load the video file as Data
            guard let data = try await item.loadTransferable(type: Data.self) else {
                print("Failed to load video data")
                return
            }
            
            // Save to temporary file to extract metadata
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            
            try data.write(to: tempURL)
            
            // Ensure cleanup happens when function scope ends
            defer {
                try? FileManager.default.removeItem(at: tempURL)
            }
            
            // Extract video metadata
            let asset = AVAsset(url: tempURL)
            let duration = try await asset.load(.duration)
            let durationInSeconds = CMTimeGetSeconds(duration)
            
            // Generate thumbnail
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let thumbnail: UIImage
            
            do {
                let time = CMTime(seconds: 0, preferredTimescale: 600)
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                thumbnail = UIImage(cgImage: cgImage)
                
                // Update the embed on main thread
                await MainActor.run {
                    currentEmbed = .video(thumbnail: thumbnail, duration: durationInSeconds)
                }
            } catch {
                print("Failed to generate thumbnail: \(error)")
            }
            
        } catch {
            print("Error loading video: \(error)")
        }
    }
    
    /// Add external link with metadata fetching
    func addExternalLink(urlString: String) async {
        guard canAddLink else { return }
        
        // Validate and normalize URL
        var urlStr = urlString.trimmingCharacters(in: .whitespaces)
        if !urlStr.hasPrefix("http://") && !urlStr.hasPrefix("https://") {
            urlStr = "https://" + urlStr
        }
        
        guard let url = URL(string: urlStr) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        await MainActor.run {
            isLoadingLink = true
        }
        
        defer {
            Task { @MainActor in
                isLoadingLink = false
                showingLinkInput = false
            }
        }
        
        do {
            // Fetch URL content
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else {
                print("Failed to decode HTML")
                await setFallbackLink(url: url)
                return
            }
            
            // Parse metadata
            let metadata = parseHTMLMetadata(html: html, url: url)
            
            // Download thumbnail if available
            var thumbnailImage: UIImage?
            if let thumbnailURLString = metadata.thumbnailURL,
               let thumbnailURL = URL(string: thumbnailURLString) {
                thumbnailImage = await downloadImage(from: thumbnailURL)
            }
            
            // Update embed
            await MainActor.run {
                currentEmbed = .external(
                    url: url,
                    title: metadata.title,
                    description: metadata.description,
                    thumbnail: thumbnailImage
                )
            }
            
        } catch {
            print("Error fetching link metadata: \(error)")
            await setFallbackLink(url: url)
        }
    }
    
    // MARK: - Private Helpers for Link Metadata
    
    private func parseHTMLMetadata(html: String, url: URL) -> (title: String?, description: String?, thumbnailURL: String?) {
        var title: String?
        var description: String?
        var thumbnailURL: String?
        
        // Extract Open Graph title
        if let ogTitleRange = html.range(of: #"<meta\s+property="og:title"\s+content="([^"]+)""#, options: .regularExpression) {
            let match = String(html[ogTitleRange])
            if let contentRange = match.range(of: #"content="([^"]+)""#, options: .regularExpression) {
                let content = String(match[contentRange])
                title = content.replacingOccurrences(of: #"content=""#, with: "").replacingOccurrences(of: "\"", with: "")
            }
        }
        
        // Fallback to <title> tag
        if title == nil, let titleRange = html.range(of: #"<title>([^<]+)</title>"#, options: .regularExpression) {
            let match = String(html[titleRange])
            title = match.replacingOccurrences(of: "<title>", with: "").replacingOccurrences(of: "</title>", with: "")
        }
        
        // Extract Open Graph description
        if let ogDescRange = html.range(of: #"<meta\s+property="og:description"\s+content="([^"]+)""#, options: .regularExpression) {
            let match = String(html[ogDescRange])
            if let contentRange = match.range(of: #"content="([^"]+)""#, options: .regularExpression) {
                let content = String(match[contentRange])
                description = content.replacingOccurrences(of: #"content=""#, with: "").replacingOccurrences(of: "\"", with: "")
            }
        }
        
        // Fallback to meta description
        if description == nil, let metaDescRange = html.range(of: #"<meta\s+name="description"\s+content="([^"]+)""#, options: .regularExpression) {
            let match = String(html[metaDescRange])
            if let contentRange = match.range(of: #"content="([^"]+)""#, options: .regularExpression) {
                let content = String(match[contentRange])
                description = content.replacingOccurrences(of: #"content=""#, with: "").replacingOccurrences(of: "\"", with: "")
            }
        }
        
        // Extract Open Graph image
        if let ogImageRange = html.range(of: #"<meta\s+property="og:image"\s+content="([^"]+)""#, options: .regularExpression) {
            let match = String(html[ogImageRange])
            if let contentRange = match.range(of: #"content="([^"]+)""#, options: .regularExpression) {
                let content = String(match[contentRange])
                thumbnailURL = content.replacingOccurrences(of: #"content=""#, with: "").replacingOccurrences(of: "\"", with: "")
            }
        }
        
        // Use domain as fallback title
        if title == nil {
            title = url.host ?? url.absoluteString
        }
        
        return (title, description, thumbnailURL)
    }
    
    private func downloadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to download thumbnail: \(error)")
            return nil
        }
    }
    
    private func setFallbackLink(url: URL) async {
        await MainActor.run {
            currentEmbed = .external(
                url: url,
                title: url.host ?? url.absoluteString,
                description: nil,
                thumbnail: nil
            )
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
    
    // MARK: - UI Presentation Helpers
    
    /// Show the image picker
    func showImagePicker() {
        guard canAddImages else { return }
        showingImagePicker = true
    }
    
    /// Show the video picker
    func showVideoPicker() {
        guard canAddVideo else { return }
        showingVideoPicker = true
    }
    
    /// Show the link input sheet
    func showLinkInput() {
        guard canAddLink else { return }
        showingLinkInput = true
    }
    
    /// Handle cancel action (check for draft)
    func handleCancel() -> Bool {
        if hasDraft {
            showingDraftAlert = true
            return false // Don't dismiss yet
        }
        return true // OK to dismiss
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
            
        }
    }
}

