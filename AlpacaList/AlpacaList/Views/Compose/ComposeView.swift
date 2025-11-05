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
    
    @State private var viewModel: ComposeViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationCoordinator.self) private var navigationCoordinator
    
    // MARK: - Initialization
    
    init(replyTo: Post? = nil) {
        _viewModel = State(wrappedValue: ComposeViewModel(replyTo: replyTo))
    }
    
    // MARK: - Body
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationView {
            VStack(spacing: 0) {
                // Reply context header
                if let replyTo = viewModel.replyTo {
                    replyContextHeader(for: replyTo)
                }
                
                // Main text editor (white background)
                ZStack(alignment: .topLeading) {
                    Color.white
                    
                    TextEditor(text: $viewModel.postText)
                        .font(.body)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    
                    if viewModel.postText.isEmpty {
                        Text(viewModel.placeholderText)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
                
                // Embed preview (images, video, link, quote)
                if let embed = viewModel.currentEmbed {
                    EmbedPreview(
                        embed: embed,
                        maxImages: viewModel.maxImages,
                        onRemoveEmbed: {
                            viewModel.removeEmbed()
                        },
                        onRemoveImage: { index in
                            viewModel.removeImage(at: index)
                        }
                    )
                }
                
                // Bottom toolbar (dark with white buttons)
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack(spacing: 0) {
                        // Media attachment buttons - evenly spaced
                        attachmentButton(icon: "photo", label: "Photos", isEnabled: viewModel.canAddImages) {
                            viewModel.showImagePicker()
                        }
                        
                        Spacer()
                        
                        attachmentButton(icon: "video", label: "Video", isEnabled: viewModel.canAddVideo) {
                            viewModel.showVideoPicker()
                        }
                        
                        Spacer()
                        
                        attachmentButton(icon: "link", label: "Link", isEnabled: viewModel.canAddLink) {
                            viewModel.showLinkInput()
                        }
                        
                        Spacer()
                        
                        // Character counter
                        Text("\(viewModel.characterCount)/\(viewModel.characterLimit)")
                            .font(.caption)
                            .foregroundColor(viewModel.isOverLimit ? .red : (viewModel.characterCount > viewModel.characterLimit - 50 ? .orange : .white.opacity(0.75)))
                    }
                    .padding()
                    .background(.regularMaterial)
                    .environment(\.colorScheme, .dark)
                }
            }
            .navigationTitle(viewModel.replyTo == nil ? "New Post" : "Reply")
            .navigationBarTitleDisplayMode(.inline)
            .alpacaListNavigationBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.handleCancel() {
                            dismiss()
                        }
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        postAction()
                    }
                    .disabled(!viewModel.canPost)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.canPost ? .white : .white.opacity(0.5))
                }
            }
            .alert("Discard Post?", isPresented: $viewModel.showingDraftAlert) {
                Button("Save Draft", role: .cancel) {
                    viewModel.saveDraft()
                    dismiss()
                }
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Do you want to save this as a draft?")
            }
            .managedPhotoPicker(
                isPresented: $viewModel.showingImagePicker,
                maxSelectionCount: viewModel.maxImages - viewModel.imageEmbedCount,
                onPhotosSelected: { items in
                    await viewModel.loadImages(from: items)
                }
            )
            .managedVideoPicker(
                isPresented: $viewModel.showingVideoPicker,
                onVideoSelected: { item in
                    await viewModel.loadVideo(from: item)
                }
            )
            .sheet(isPresented: $viewModel.showingLinkInput) {
                LinkInputSheet(
                    isPresented: $viewModel.showingLinkInput,
                    isLoading: viewModel.isLoadingLink,
                    onAdd: { urlString in
                        await viewModel.addExternalLink(urlString: urlString)
                    }
                )
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
        Task {
            do {
                try await viewModel.createPost()
                dismiss()
            } catch {
                // TODO: Show error alert to user
                print("Error posting: \(error)")
            }
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
                .environment(NavigationCoordinator())
                .previewDisplayName("New Post")
            
            // Reply preview
            ComposeView(replyTo: mockPost)
                .environment(NavigationCoordinator())
                .previewDisplayName("Reply")
        }
    }
}

