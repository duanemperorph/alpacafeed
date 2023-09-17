//
//  TopBarContainer.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/4/23.
//

import SwiftUI

struct TopBarContainer: View {
    @Environment(\.colorScheme) var envColorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var communityName = "lemmyworld@lemmy.world"
    @State var userName = "imacat@kbin.social"
    
    @EnvironmentObject var topBarController: TopBarController
    
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
    
    var body: some View {
        VStack {
            if (topBarController.isExpanded) {
                TopBarExpanded(
                    communityName: $communityName,
                    userName: $userName
                )
            }
            else {
                TopBarMinimized(communityName: "lemmyworld@lemmy.world", icon: "globe")
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
