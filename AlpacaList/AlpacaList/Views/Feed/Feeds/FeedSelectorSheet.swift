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
    case discover = "Discover"
}

// MARK: - Feed Selector Sheet

struct FeedSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedFeed: FeedType
    @State private var selectedTab: FeedSelectorTab = .myFeeds
    
    // Mock data for now - will be replaced with API data
    let savedFeeds: [SavedFeed]
    let suggestedFeeds: [SavedFeed]
    
    init(
        selectedFeed: Binding<FeedType>,
        savedFeeds: [SavedFeed] = SavedFeed.mockSavedFeeds,
        suggestedFeeds: [SavedFeed] = SavedFeed.mockSuggestedFeeds
    ) {
        self._selectedFeed = selectedFeed
        self.savedFeeds = savedFeeds
        self.suggestedFeeds = suggestedFeeds
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
                    case .discover:
                        discoverContent
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
            
            // Saved feeds
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
            }
        }
        .listRowBackground(Color.clear.background(.thinMaterial))
    }
    
    // MARK: - Discover Tab
    
    @ViewBuilder
    private var discoverContent: some View {
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
                        // TODO: Pin feed to saved feeds via API
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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            FeedSelectorSheet(selectedFeed: .constant(.following))
        }
        .tint(Color(red: 0.75, green: 0.25, blue: 0.75))
        
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            FeedSelectorSheet(
                selectedFeed: .constant(.custom(SavedFeed.mockSavedFeeds[0]))
            )
        }
        .tint(Color(red: 0.75, green: 0.25, blue: 0.75))
        .previewDisplayName("With Custom Feed Selected")
    }
}

