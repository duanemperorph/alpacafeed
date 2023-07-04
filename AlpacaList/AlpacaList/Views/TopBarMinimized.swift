//
//  TopBarMinimized.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/4/23.
//

import SwiftUI

struct TopBarMinimized: View {
    @Environment(\.colorScheme) var envColorScheme
    
    @State var communityName = "lemmyworld@lemmy.world"
    

    var backgroundColorScheme: ColorScheme {
        return envColorScheme == .dark ? ColorScheme.light : ColorScheme.dark
    }
    
    var body: some View {
        HStack {
            Text(communityName)
        }
        .font(.system(size: 18))
        .frame(maxWidth: .infinity, maxHeight: 20)
        .padding(.horizontal, 8)
        .padding(.vertical)
        .background(.thinMaterial)
        .environment(\.colorScheme, backgroundColorScheme)
    }
}

struct TopBarMinimized_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            TopBarMinimized()
        }
    }
}
