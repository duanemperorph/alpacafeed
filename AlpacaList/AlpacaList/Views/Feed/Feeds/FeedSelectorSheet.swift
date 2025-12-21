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
    @State private var feedToRemove: SavedFeed?
    @State private var showingRemoveConfirmation = false
    
    // Computed from AppState
    private var savedFeeds: [SavedFeed] {
        appState.savedFeedsRepository.savedFeeds
    }
    
    private var suggestedFeeds: [SavedFeed] {
        appState.savedFeedsRepository.suggestedFeeds
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
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        feedToRemove = feed
                        showingRemoveConfirmation = true
                    } label: {
                        Label("Remove", systemImage: "minus.circle")
                    }
                }
            }
        }
        .listRowBackground(Color.clear.background(.thinMaterial))
        .alert("Remove Feed", isPresented: $showingRemoveConfirmation, presenting: feedToRemove) { feed in
            Button("Cancel", role: .cancel) {
                feedToRemove = nil
            }
            Button("Remove", role: .destructive) {
                Task {
                    try? await appState.savedFeedsRepository.unpinFeed(uri: feed.uri)
                    
                    // If the removed feed was selected, switch to Following
                    if selectedFeed == .custom(feed) {
                        selectedFeed = .following
                    }
                }
                feedToRemove = nil
            }
        } message: { feed in
            Text("Remove \"\(feed.name)\" from your saved feeds?")
        }
    }
    
    // MARK: - Explore Tab
    
    @ViewBuilder
    private var exploreContent: some View {
        Section {
            ForEach(suggestedFeeds) { feed in
                FeedRow(
                    name: feed.name,
                    description: feed.description,
                    creator: feed.creator,
                    isSelected: false,
                    showPinButton: true,
                    onTap: {
                        // For now, just select it
                        selectedFeed = .custom(feed)
                        dismiss()
                    },
                    onPin: {
                        Task {
                            try? await appState.savedFeedsRepository.pinFeed(feed)
                        }
                    }
                )
            }
        }
        .listRowBackground(Color.clear.background(.thinMaterial))
    }
}

// MARK: - Feed Row

struct FeedRow: View {
    let name: String
    let description: String?
    var creator: String? = nil
    let isSelected: Bool
    var showPinButton: Bool = false
    let onTap: () -> Void
    var onPin: (() -> Void)? = nil
    
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
                
                // Selection indicator or pin button
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 22))
                } else if showPinButton, let onPin = onPin {
                    Button(action: onPin) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 22))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
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

