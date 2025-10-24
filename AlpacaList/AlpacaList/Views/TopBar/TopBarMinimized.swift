//
//  TopBarMinimized.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/4/23.
//

import SwiftUI

struct TopBarButtonMinimized: View {
//    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
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
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @Binding var userName: String
    
    var body: some View {
        HStack {
            if navigationCoordinator.canPop {
                Button(action: {
                    navigationCoordinator.pop()
                }) {
                    Image(systemName: "chevron.left")
                }
                .foregroundColor(.white)
                .font(.system(size: 22)).fontWeight(.semibold)
                Spacer().frame(width: 15)
            }
            TopBarButtonMinimized(imageName: "person.circle", text: userName)
        }
        .font(.system(size: 18))
        .frame(maxWidth: .infinity, maxHeight: 20)
        .padding(10)
        .padding(.vertical)
    }
}

struct TopBarMinimized_Previews: PreviewProvider {
    private static let navigationCoordinatorCannotPop = NavigationCoordinator()
    private static let navigationCoordinatorCanPop = NavigationCoordinator(initialStack: [.timeline(type: .home)])
    
    @ViewBuilder static var createPreview: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            VStack {
                TopBarMinimized(userName: .constant("alice.bsky.social"))
                    .environmentObject(navigationCoordinatorCannotPop)
                TopBarMinimized(userName: .constant("alice.bsky.social"))
                    .environmentObject(navigationCoordinatorCanPop)
            }
            .background(.regularMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
    
    static var previews: some View {
        createPreview
        createPreview
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewDisplayName("iPad Pro 11\"")
    }
}
