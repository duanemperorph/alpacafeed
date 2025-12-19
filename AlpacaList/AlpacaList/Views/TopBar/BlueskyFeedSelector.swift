//
//  BlueskyFeedSelector.swift
//  AlpacaList
//
//  Feed type selector for Bluesky mode
//

import SwiftUI

// MARK: - Feed Selector Pill Style

struct FeedSelectorPillStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30)
            .padding(.horizontal, 15)
            .foregroundColor(.white)
            .font(.system(size: 16))
            .fontWeight(.semibold)
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}

extension View {
    func feedSelectorPillStyle() -> some View {
        modifier(FeedSelectorPillStyle())
    }
}

// MARK: - Feed Type

enum FeedType: String, CaseIterable {
    case following = "Following"
    case discover = "Discover"
    case custom = "Custom"
}

// MARK: - Feed Selector

struct BlueskyFeedSelector: View {
    @Binding var selectedFeed: FeedType
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 14))
                .fontWeight(.bold)
                .onTapGesture {
                    cycleFeed(backwards: true)
                }
            
            Text(selectedFeed.rawValue)
                .frame(maxWidth: .infinity)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .fontWeight(.bold)
                .onTapGesture {
                    cycleFeed(backwards: false)
                }
        }
        .feedSelectorPillStyle()
    }
    
    private func cycleFeed(backwards: Bool) {
        let allCases = FeedType.allCases
        guard let currentIndex = allCases.firstIndex(of: selectedFeed) else { return }
        
        let nextIndex = backwards
            ? (currentIndex - 1 + allCases.count) % allCases.count
            : (currentIndex + 1) % allCases.count
        
        selectedFeed = allCases[nextIndex]
    }
}

// MARK: - Previews

struct BlueskyFeedSelector_Previews: PreviewProvider {
    @State static var selectedFeed: FeedType = .following
    
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                BlueskyFeedSelector(selectedFeed: $selectedFeed)
                    .frame(width: 150)
                
                BlueskyFeedSelector(selectedFeed: .constant(.discover))
                    .frame(width: 200)
            }
            .padding()
            .background(.regularMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}

