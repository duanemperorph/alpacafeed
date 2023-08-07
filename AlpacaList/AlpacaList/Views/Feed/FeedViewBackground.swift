//
//  FeedViewBackground.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/23/23.
//

import SwiftUI

struct FeedViewBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct FeedViewBackground_Previews: PreviewProvider {
    static var previews: some View {
        FeedViewBackground()
    }
}
