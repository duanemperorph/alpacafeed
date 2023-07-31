//
//  FeedItemButtons.swift
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

struct FeedItemExpandCommentsButton: View {
    @State var isActive = false
    
    var body: some View {
        Button {
            isActive.toggle()
        } label: {
            Image(systemName: isActive ? "chevron.up" : "chevron.down")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .postItemButtonStyle(isActive: isActive)
        }
    }
}

// FeedItemButtonWithCount
// contains a button with a customizable label view and a count
struct FeedItemButtonWithCount<Content: View>: View {
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
        }.buttonStyle(.plain)
    }
}

struct FeedItemButtons: View {
    var body: some View {
        VStack {
            HStack {
                FeedItemButtonWithCount(action: {
                    // Action for upvote button
                }, iconView: {
                    Image(systemName: "hand.thumbsup")
                })
                
                Spacer()
                
                FeedItemButtonWithCount(action: {
                    // Action for downvote button
                }, iconView: {
                    Image(systemName: "hand.thumbsdown")
                })
                
                Spacer()
                
                // Add more FeedItemButtonWithCount instances for other buttons if needed
                
                FeedItemButtonWithCount(action: {
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
                FeedItemExpandCommentsButton()
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
                }.frame(width: 40).buttonStyle(.borderless)
            }
        }
        .tint(.primary)
    }
}

struct FeedItemButtons_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            FeedViewBackground()
            FeedItemButtons()
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}
