//
//  TopBarMinimized.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/4/23.
//

import SwiftUI

struct TopBarButtonMinimized: View {
//    @EnvironmentObject var navigationRootController: NavigationRootController
    
    var imageName: String
    var text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: imageName)
                .font(.system(size: 20))
                .frame(width: 20, height: 20)
            Text(text)
                .font(.system(size: 18))
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer().frame(width: 20)
        }
        .foregroundColor(.white.opacity(0.75))
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 40)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.75), lineWidth: 0.75)
        )
    }
}

struct TopBarMinimized: View {
    var communityName: String
    var icon: String
    
    @EnvironmentObject var navigationRootController: NavigationRootController
    
    var body: some View {
        HStack {
            if navigationRootController.canPop {
                Button(action: {
                    navigationRootController.pop()
                }) {
                    Image(systemName: "chevron.left")
                }
                .foregroundColor(.white)
                .font(.system(size: 22)).fontWeight(.semibold)
                Spacer().frame(width: 15)
            }
            TopBarButtonMinimized(imageName: icon, text: communityName)
        }
        .font(.system(size: 18))
        .frame(maxWidth: .infinity, maxHeight: 20)
        .padding(10)
        .padding(.vertical)
    }
}

struct TopBarMinimized_Previews: PreviewProvider {
    private static let navigationControllerCannotPop = NavigationRootController()
    private static let navigationControllerCanPop = NavigationRootController(initialStack: [.postDetails(postItem: MockDataGenerator.generateRandomComment(maxLength: 1, depth: 1, indention: 1))])
    
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            VStack {
                TopBarMinimized(communityName: "lemmyworld@lemmy.world", icon: "globe")
                    .environmentObject(navigationControllerCannotPop)
                TopBarMinimized(communityName: "lemmyworld@lemmy.world", icon: "globe")
                    .environmentObject(navigationControllerCanPop)
            }
            .background(.regularMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}
