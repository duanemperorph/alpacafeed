//
//  ComposeView.swift
//  AlpacaList
//
//  Compose view for creating new posts and replies
//

import SwiftUI
import PhotosUI

struct ComposeView: View {
    // MARK: - Properties
    
    let replyTo: Post?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    @State private var postText: String = ""
    @State private var showingDraftAlert = false
    
    // Generalized embed tracking (only ONE embed allowed per post)
    @State private var currentEmbed: PendingEmbed? = nil
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showingImagePicker = false
    
    // Character limit for Bluesky posts
    private let characterLimit = 300
    private let maxImages = 4
    
    // MARK: - Computed Properties
    
    private var characterCount: Int {
        postText.count
    }
    
    private var isOverLimit: Bool {
        characterCount > characterLimit
    }
    
    private var canPost: Bool {
        let hasText = !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasEmbed = currentEmbed != nil
        return (hasText || hasEmbed) && !isOverLimit
    }
    
    private var canAddImages: Bool {
        guard let embed = currentEmbed else { return true }
        return embed.hasImages && embed.imageCount < maxImages
    }
    
    private var imageEmbedCount: Int {
        currentEmbed?.imageCount ?? 0
    }
    
    private var hasQuotePost: Bool {
        currentEmbed?.isQuotePost ?? false
    }
    
    private var hasImages: Bool {
        currentEmbed?.hasImages ?? false
    }
    
    private var placeholderText: String {
        if let replyTo = replyTo {
            return "Reply to @\(replyTo.author.handle)..."
        } else {
            return "What's on your mind?"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Reply context header
                if let replyTo = replyTo {
                    replyContextHeader(for: replyTo)
                }
                
                // Main text editor (white background)
                ZStack(alignment: .topLeading) {
                    Color.white
                    
                    TextEditor(text: $postText)
                        .font(.body)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    
                    if postText.isEmpty {
                        Text(placeholderText)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
                
                // Embed preview (images, video, link, quote)
                if let embed = currentEmbed {
                    EmbedPreview(
                        embed: embed,
                        maxImages: maxImages,
                        onRemoveEmbed: {
                            currentEmbed = nil
                        },
                        onRemoveImage: { index in
                            removeImage(at: index)
                        }
                    )
                }
                
                // Bottom toolbar (dark with white buttons)
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack(spacing: 0) {
                        // Media attachment buttons - evenly spaced
                        attachmentButton(icon: "photo", label: "Photos", isEnabled: canAddImages) {
                            showingImagePicker = true
                        }
                        
                        Spacer()
                        
                        attachmentButton(icon: "video", label: "Video", isEnabled: false) {
                            // TODO: Implement video picker
                        }
                        
                        Spacer()
                        
                        attachmentButton(icon: "link", label: "Link", isEnabled: false) {
                            // TODO: Implement link preview
                        }
                        
                        Spacer()
                        
                        attachmentButton(icon: "quote.bubble", label: "Quote", isEnabled: false) {
                            // TODO: Implement quote post
                        }
                        
                        Spacer()
                        
                        // Character counter
                        Text("\(characterCount)/\(characterLimit)")
                            .font(.caption)
                            .foregroundColor(isOverLimit ? .red : (characterCount > characterLimit - 50 ? .orange : .white.opacity(0.75)))
                    }
                    .padding()
                    .background(.regularMaterial)
                    .environment(\.colorScheme, .dark)
                }
            }
            .navigationTitle(replyTo == nil ? "New Post" : "Reply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if !postText.isEmpty {
                            showingDraftAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        postAction()
                    }
                    .disabled(!canPost)
                    .fontWeight(.bold)
                    .foregroundColor(canPost ? .white : .white.opacity(0.5))
                }
            }
            .alert("Discard Post?", isPresented: $showingDraftAlert) {
                Button("Save Draft", role: .cancel) {
                    // TODO: Implement draft saving
                    dismiss()
                }
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Do you want to save this as a draft?")
            }
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedPhotoItems,
                maxSelectionCount: maxImages - imageEmbedCount,
                matching: .images
            )
            .onChange(of: selectedPhotoItems) { oldItems, newItems in
                Task {
                    await loadImages(from: newItems)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func replyContextHeader(for post: Post) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Replying to")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("@\(post.author.handle)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Text(post.text)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        
        Divider()
            .background(Color.gray.opacity(0.3))
    }
    
    private func attachmentButton(icon: String, label: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
        .accessibilityLabel(label)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
    
    // MARK: - Actions
    
    private func postAction() {
        // TODO: Implement actual post creation with API
        print("Posting: \(postText)")
        if let replyTo = replyTo {
            print("Reply to: \(replyTo.uri)")
        }
        
        if let embed = currentEmbed {
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
        
        dismiss()
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
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
            
            selectedPhotoItems = []
        }
    }
    
    private func removeImage(at index: Int) {
        guard case .images(var images) = currentEmbed else { return }
        images.remove(at: index)
        
        if images.isEmpty {
            currentEmbed = nil
        } else {
            currentEmbed = .images(images)
        }
    }
}

// MARK: - Previews

struct ComposeView_Previews: PreviewProvider {
    static var mockAuthor: Author {
        Author(
            did: "did:plc:abc123",
            handle: "alice.bsky.social",
            displayName: "Alice",
            avatar: "alpaca1"
        )
    }
    
    static var mockPost: Post {
        Post.createTextPost(
            author: mockAuthor,
            text: "This is a sample post to test the reply functionality."
        )
    }
    
    static var previews: some View {
        // New post preview
        Group {
            ComposeView(replyTo: nil)
                .environmentObject(NavigationCoordinator())
                .previewDisplayName("New Post")
            
            // Reply preview
            ComposeView(replyTo: mockPost)
                .environmentObject(NavigationCoordinator())
                .previewDisplayName("Reply")
        }
    }
}

