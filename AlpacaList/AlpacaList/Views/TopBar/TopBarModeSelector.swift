//
//  TopBarModeSelector.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/17/23.
//

import SwiftUI

struct ModeSelectorCollapsed: View {
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

struct ModeSelectorSegmentedControl: View {
    @State private var favoriteColor = 0

    var body: some View {
        VStack {
            HStack {
                Picker("What is your favorite color?", selection: $favoriteColor) {
                    Text("Red").tag(0)
                    Text("Green").tag(1)
                    Text("Blue").tag(2)
                }
            }
            .cornerRadius(15)
            .frame(width: .infinity, height: 30)
            .pickerStyle(.segmented)
            .padding(.horizontal, 15)
            .foregroundColor(.white)
            .font(.system(size: 16)).fontWeight(.semibold)
            .background(Color.white.opacity(0.1)).cornerRadius(15)
            .overlay( /// apply a rounded border
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )


            Text("Value: \(favoriteColor)")
        }
    }
}

struct TopBarModeSelector: View {
    var body: some View {
        ModeSelectorCollapsed()
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
                TopBarModeSelector()
            }
            .background(.regularMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}
