//
//  FeedItemButtons.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/23/23.
//

import SwiftUI

struct PostItemButtons: View {
    var body: some View {
        HStack {
            ThumbUpButton()
            Spacer()
            ThumbDownButton()
            Spacer()
            BoostButton()
            Spacer()
            CommentsCountView()
        }
        .tint(.primary)
    }
}

struct PostItemButtons_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            FeedViewBackground()
            PostItemButtons()
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}
