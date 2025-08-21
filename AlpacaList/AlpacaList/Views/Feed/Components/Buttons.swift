//
//  Buttons.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/6/23.
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

struct ExpandCommentsButton: View {
    let isActive: Bool
    let toggleActive: () -> Void
    
    var body: some View {
        Button {
            print("toggling \(isActive)")
            toggleActive()
        } label: {
            Image(systemName: isActive ? "chevron.up" : "chevron.down")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .postItemButtonStyle(isActive: isActive)
        }.buttonStyle(.borderless)
    }
}

// FeedItemButtonWithCount
// contains a button with a customizable label view and a count
struct ButtonWithCount<Content: View>: View {
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

struct ThumbUpButton: View {
    var body: some View {
        ButtonWithCount(action: {
            // Action for upvote button
        }, iconView: {
            Image(systemName: "hand.thumbsup")
        })
    }
}

struct ThumbDownButton: View {
    var body: some View {
        ButtonWithCount(action: {
            // Action for downvote button
        }, iconView: {
            Image(systemName: "hand.thumbsdown")
        })
    }
}

struct BoostButton: View {
    var body: some View {
        ButtonWithCount(action: {
            // Action for boost button
        }, iconView: {
            Text("🚀")
        })
    }

}

struct PlusButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .fontWeight(.bold)
                .frame(width: 18, height: 18)
        }
        .frame(width: 40)
        .buttonStyle(.borderless)
    }
}

struct CommentsCountView: View {
    @State private var textValue = "100"
    
    var body: some View {
        HStack {
            Image(systemName: "bubble.left")
            Text(textValue)
        }
        .frame(width: 60)
    }
}

