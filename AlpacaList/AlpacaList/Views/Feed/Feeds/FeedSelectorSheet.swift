//
//  FeedSelectorSheet.swift
//  AlpacaList
//
//  Sheet for selecting feeds with tabs for My Feeds and Discover
//

import SwiftUI

// MARK: - Feed Selector Tab

enum FeedSelectorTab: String, CaseIterable {
    case myFeeds = "My Feeds"
    case explore = "Explore"
}

// MARK: - Feed Selector Sheet

struct FeedSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @Binding var selectedFeed: FeedType
    @State private var selectedTab: FeedSelectorTab = .myFeeds
    
    /// Track feeds currently being added (by URI)
    @State private var feedsBeingAdded: Set<String> = []
    /// Track feeds currently being removed (by URI)
    @State private var feedsBeingRemoved: Set<String> = []
    
    // Computed from AppState
    private var savedFeeds: [SavedFeed] {
        appState.savedFeedsRepository.savedFeeds
    }
    
    private var suggestedFeeds: [SavedFeed] {
        appState.savedFeedsRepository.suggestedFeeds
    }
    
    /// Check if a feed URI is already saved
    private func isFeedSaved(_ uri: String) -> Bool {
        savedFeeds.contains { $0.uri == uri }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab picker
                Picker("", selection: $selectedTab) {
                    ForEach(FeedSelectorTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content based on selected tab
                List {
                    switch selectedTab {
                    case .myFeeds:
                        myFeedsContent
                    case .explore:
                        exploreContent
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .background(.ultraThinMaterial)
            .navigationTitle("Choose Feed")
            .navigationBarTitleDisplayMode(.inline)
            .alpacaListNavigationBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - My Feeds Tab
    
    @ViewBuilder
    private var myFeedsContent: some View {
        Section {
            // Following is always first
            FeedRow(
                name: "Following",
                description: "Posts from people you follow",
                isSelected: selectedFeed == .following,
                onTap: {
                    selectedFeed = .following
                    dismiss()
                }
            )
            
            // Saved feeds (swipe to remove)
            ForEach(savedFeeds) { feed in
                FeedRow(
                    name: feed.name,
                    description: feed.description,
                    creator: feed.creator,
                    isSelected: selectedFeed == .custom(feed),
                    onTap: {
                        selectedFeed = .custom(feed)
                        dismiss()
                    }
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            try? await appState.savedFeedsRepository.unpinFeed(uri: feed.uri)
                            
                            // If the removed feed was selected, switch to Following
                            if selectedFeed == .custom(feed) {
                                selectedFeed = .following
                            }
                        }
                    } label: {
                        Label("Remove", systemImage: "minus.circle")
                    }
                }
            }
        }
        .listRowBackground(Color.clear.background(.thinMaterial))
    }
    
    // MARK: - Explore Tab
    
    @ViewBuilder
    private var exploreContent: some View {
        Section {
            ForEach(suggestedFeeds) { feed in
                let isSaved = isFeedSaved(feed.uri)
                let isAdding = feedsBeingAdded.contains(feed.uri)
                let isRemoving = feedsBeingRemoved.contains(feed.uri)
                
                FeedRow(
                    name: feed.name,
                    description: feed.description,
                    creator: feed.creator,
                    isSelected: false,
                    actionState: isAdding ? .adding : (isRemoving ? .removing : (isSaved ? .added : .add)),
                    onTap: {
                        selectedFeed = .custom(feed)
                        dismiss()
                    },
                    onAdd: {
                        guard !feedsBeingAdded.contains(feed.uri) else { return }
                        feedsBeingAdded.insert(feed.uri)
                        Task {
                            try? await appState.savedFeedsRepository.pinFeed(feed)
                            feedsBeingAdded.remove(feed.uri)
                        }
                    },
                    onRemove: {
                        guard !feedsBeingRemoved.contains(feed.uri) else { return }
                        feedsBeingRemoved.insert(feed.uri)
                        Task {
                            try? await appState.savedFeedsRepository.unpinFeed(uri: feed.uri)
                            feedsBeingRemoved.remove(feed.uri)
                        }
                    }
                )
            }
        }
        .listRowBackground(Color.clear.background(.thinMaterial))
    }
}

// MARK: - Feed Row Action State

enum FeedRowActionState {
    case none       // No action button (used in My Feeds tab)
    case add        // Show "+" button to add
    case adding     // Show spinner while adding
    case added      // Show checkmark with remove option
    case removing   // Show spinner while removing
}

// MARK: - Feed Row

struct FeedRow: View {
    let name: String
    let description: String?
    var creator: String? = nil
    let isSelected: Bool
    var actionState: FeedRowActionState = .none
    let onTap: () -> Void
    var onAdd: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Feed icon placeholder
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 16))
                    )
                
                // Feed info
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundColor(.primary)
                    
                    if let description = description {
                        Text(description)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    if let creator = creator {
                        Text("by \(creator)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Selection indicator or action button
                actionView
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var actionView: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentColor)
                .font(.system(size: 22))
        } else {
            switch actionState {
            case .none:
                EmptyView()
                
            case .add:
                Button(action: { onAdd?() }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 22))
                }
                .buttonStyle(.plain)
                
            case .adding, .removing:
                ProgressView()
                    .frame(width: 22, height: 22)
                
            case .added:
                Button(action: { onRemove?() }) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.red.opacity(0.8))
                        .font(.system(size: 22))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Previews

struct FeedSelectorSheet_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            FeedSelectorSheet(selectedFeed: .constant(.following))
        }
        .environment(appState)
        .tint(Color(red: 0.75, green: 0.25, blue: 0.75))
    }
}

