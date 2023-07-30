//
//  PostItemButtons.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/23/23.
//

import SwiftUI

extension View {
    @ViewBuilder func postItemButtonStyle(isActive: Bool) -> some View {
        if (isActive) {
            self
                .postItemButtonStyle()
                .postItemButtonActiveStyle()
        }
        else {
            self.postItemButtonStyle()
        }
    }
    
    func postItemButtonStyle() -> some View {
        return self
            .padding (5)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.5), lineWidth: 1)
                )
    }
    
    func postItemButtonActiveStyle() -> some View {
        return self
            .background(Color.purple)
            .cornerRadius(8)
    }
}

struct PostItemExpandCommentsButton: View {
    @State var isActive = false
    
    var body: some View {
        Button {
            isActive.toggle()
        } label: {
            VStack {
                Image(systemName: isActive ? "chevron.up" : "chevron.down")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .postItemButtonStyle(isActive: isActive)
        }
    }
}

// PostItemButtonWithCount
// contains a button with a customizable label view and a count
struct PostItemButtonWithCount<Content: View>: View {
    let count = 100
    @State var isActive = false
    let action: () -> Void
    @ViewBuilder let iconView: () -> Content
    
    var body: some View {
        Button {
            isActive.toggle()
        } label: {
            HStack {
                iconView().fontWeight(.bold)
                Text(String(count))
            }
            .postItemButtonStyle(isActive: isActive)
        }
    }
}

struct PostItemButtons: View {
    var body: some View {
        VStack {
            HStack {
                PostItemButtonWithCount(action: {
                    // Action for upvote button
                }, iconView: {
                    Image(systemName: "hand.thumbsup")
                })
                
                Spacer()
                
                PostItemButtonWithCount(action: {
                    // Action for downvote button
                }, iconView: {
                    Image(systemName: "hand.thumbsdown")
                })
                
                Spacer()
                
                // Add more PostItemButtonWithCount instances for other buttons if needed
                
                PostItemButtonWithCount(action: {
                    // Action for boost button
                }, iconView: {
                    Text("🚀")
                })
                
            }
            Spacer().frame(height: 20)
            HStack {
                HStack {
                    Image(systemName: "bubble.left")
                    Text("100")
                }
                .frame(width: 60)
                PostItemExpandCommentsButton()
                    .padding(.horizontal, 10)
                HStack {
                    
                    Button {
                        // TOOO
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .fontWeight(.bold)
                            .frame(width: 18, height: 18)
                    }
                }.frame(width: 40)
            }
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
