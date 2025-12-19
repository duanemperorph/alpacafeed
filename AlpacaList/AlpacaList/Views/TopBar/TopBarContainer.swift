//
//  TopBarContainer.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/4/23.
//

import SwiftUI

struct TopBarContainer: View {
    @Environment(\.colorScheme) var envColorScheme
    @Environment(TopBarController.self) private var topBarController
    @Environment(AppState.self) private var appState
    
    var backgroundColorScheme: ColorScheme {
        return envColorScheme == .dark ? ColorScheme.light : ColorScheme.dark
    }
    
    var topBarTap: some Gesture {
        TapGesture().onEnded { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                topBarController.expand()
            }
        }
    }
    
    @ViewBuilder var minimizedContent: some View {
        if !appState.isSessionRestored {
            EmptyView()
        } else if let handle = appState.currentHandle {
            TopBarMinimized(text: handle)
        } else {
            TopBarMinimized(imageName: "person.badge.plus", text: "Sign in to Bluesky")
        }
    }
    
    var body: some View {
        VStack {
            if (topBarController.isExpanded) {
                TopBarExpanded()
            }
            else {
                minimizedContent
                    .contentShape(Rectangle())
                    .gesture(topBarTap)
            }
        }
        .background(.regularMaterial)
        .environment(\.colorScheme, backgroundColorScheme)
    }
}

//struct TopBarContainer_Previews: PreviewProvider {
//    @State static var isOpen = false
//
//    static var previews: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [.blue, .purple]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .edgesIgnoringSafeArea(.all)
//            TopBarContainer()
//        }
//    }
//}
