//
//  TopBarModeSelector.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/17/23.
//

import SwiftUI

struct TopBarModeSelectorButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity, maxHeight: 30)
        }
        .tint(.primary)
        .buttonStyle(.borderless)
        .font(.system(size: 16)).fontWeight(.semibold)
        .background(Color.white.opacity(0.1)).cornerRadius(15)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}

struct TopBarModeSelector: View {
    @State var collapsed = false
    
    var options = ["red", "blue", "green"]
    
    var selected = "blue"
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.left").font(.system(size: 14)).fontWeight(.bold)
            Text("Your Text")
                .frame(maxWidth: .infinity)
            Image(systemName: "chevron.right").font(.system(size: 14)).fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30)
        .padding(.horizontal, 15)
        .foregroundColor(.white)
        .font(.system(size: 16)).fontWeight(.semibold)
        .background(Color.white.opacity(0.1)).cornerRadius(15)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
    }
}

struct TopBarContainer_Previews: PreviewProvider {
    @State static var isOpen = false

    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            VStack {
                TopBarModeSelectorButton(title: "meow") {}
                    .frame(width: .infinity, height: 40)
            }
            .frame(width: 200, height: 50)
            .background(.regularMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}
