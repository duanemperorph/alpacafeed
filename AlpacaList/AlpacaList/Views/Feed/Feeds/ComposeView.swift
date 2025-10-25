//
//  ComposeView.swift
//  AlpacaList
//
//  Compose view for creating new posts and replies
//

import SwiftUI

struct ComposeView: View {
    // MARK: - Properties
    
    let replyTo: Post?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    @State private var postText: String = ""
    @State private var showingDraftAlert = false
    
    // Character limit for Bluesky posts
    private let characterLimit = 300
    
    // MARK: - Computed Properties
    
    private var characterCount: Int {
        postText.count
    }
    
    private var isOverLimit: Bool {
        characterCount > characterLimit
    }
    
    private var canPost: Bool {
        !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isOverLimit
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
                
                // Bottom toolbar (dark with white buttons)
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack(spacing: 16) {
                        // Media attachment buttons (placeholders)
                        HStack(spacing: 12) {
                            attachmentButton(icon: "photo", label: "Photos") {
                                // TODO: Implement image picker
                            }
                            
                            attachmentButton(icon: "video", label: "Video") {
                                // TODO: Implement video picker
                            }
                            
                            attachmentButton(icon: "link", label: "Link") {
                                // TODO: Implement link preview
                            }
                            
                            attachmentButton(icon: "quote.bubble", label: "Quote") {
                                // TODO: Implement quote post
                            }
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
    
    private func attachmentButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
        .accessibilityLabel(label)
        .disabled(true) // Disabled until implemented
        .opacity(0.5) // Visual indicator that it's not yet available
    }
    
    // MARK: - Actions
    
    private func postAction() {
        // TODO: Implement actual post creation with API
        print("Posting: \(postText)")
        if let replyTo = replyTo {
            print("Reply to: \(replyTo.uri)")
        }
        dismiss()
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

