//
//  TopBarMinimized.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/4/23.
//

import SwiftUI

struct TopBarButtonMinimized: View {
    var imageName: String
    @Binding var text: String
    
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
    @Binding var communityName: String
    
    var body: some View {
        HStack {
            TopBarButtonMinimized(imageName: "chevron.down.circle", text: $communityName)
        }
        .font(.system(size: 18))
        .frame(maxWidth: .infinity, maxHeight: 20)
        .padding(10)
        .padding(.vertical)
    }
}

struct TopBarMinimized_Previews: PreviewProvider {
    @State static var communityName = "lemmyworld@lemmy.world"
    
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            VStack {
                TopBarMinimized(communityName: $communityName)
            }
            .background(.regularMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}
