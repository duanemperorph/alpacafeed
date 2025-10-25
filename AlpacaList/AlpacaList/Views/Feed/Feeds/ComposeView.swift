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
    
    // Image attachment state
    @State private var selectedImages: [UIImage] = []
    @State private var imageAltTexts: [String] = [] // Alt text for each image
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
        let hasImages = !selectedImages.isEmpty
        return (hasText || hasImages) && !isOverLimit
    }
    
    private var canAddImages: Bool {
        selectedImages.count < maxImages
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
                
                // Image preview grid
                if !selectedImages.isEmpty {
                    imagePreviewGrid
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
                maxSelectionCount: maxImages - selectedImages.count,
                matching: .images
            )
            .onChange(of: selectedPhotoItems) { newItems in
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
    
    private var imagePreviewGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                        imagePreviewCard(image: image, index: index)
                    }
                }
                .padding(.horizontal)
            }
            
            // Image count indicator
            HStack {
                Image(systemName: "photo.stack")
                    .foregroundColor(.secondary)
                Text("\(selectedImages.count) of \(maxImages) images")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private func imagePreviewCard(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Remove button
            Button {
                removeImage(at: index)
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
        
        if !selectedImages.isEmpty {
            print("With \(selectedImages.count) images")
            // TODO: Upload images and create Embed.images
            // For now, this would create:
            // let imageEmbeds = selectedImages.enumerated().map { index, image in
            //     Embed.ImageEmbed(
            //         thumb: "uploaded_thumb_url",
            //         fullsize: "uploaded_fullsize_url",
            //         alt: imageAltTexts[index],
            //         aspectRatio: Embed.AspectRatio(width: Int(image.size.width), height: Int(image.size.height))
            //     )
            // }
            // embed = .images(imageEmbeds)
        }
        
        dismiss()
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImages.append(image)
                    imageAltTexts.append("") // Default empty alt text
                }
            }
        }
        // Clear selection after loading
        await MainActor.run {
            selectedPhotoItems = []
        }
    }
    
    private func removeImage(at index: Int) {
        selectedImages.remove(at: index)
        imageAltTexts.remove(at: index)
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

