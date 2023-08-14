//
//  CommentsButtons.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/6/23.
//

import SwiftUI

struct CommentItemButtons: View {
    let item: FeedItem
    let toggleExpanded: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                ThumbUpButton()
                Spacer()
                ThumbDownButton()
                Spacer()
                BoostButton()
                
            }
            Spacer().frame(height: 20)
            HStack {
                CommentsCountView()
                .frame(width: 60)
                ExpandCommentsButton(isActive: item.isExpanded, toggleActive: toggleExpanded)
                    .padding(.horizontal, 10)
                PlusButton().frame(width: 40)
            }
        }
        .tint(.primary)
    }
}

//struct CommentItemButtons_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        ZStack {
//            FeedViewBackground()
//            CommentItemButtons()
//                .padding(10)
//                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
//        }
//    }
//}
