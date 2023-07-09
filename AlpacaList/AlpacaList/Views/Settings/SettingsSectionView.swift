//
//  SettingsSectionView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/9/23.
//

import SwiftUI

struct SettingsSectionView<ContentView: View>: View {
    @ViewBuilder var content: ContentView
    var title: String?
    
    init(title: String? = nil, @ViewBuilder content: () -> ContentView) {
        self.title = title
        self.content = content()
    }
    
    //constructor with just the content
    init(@ViewBuilder content: () -> ContentView) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            VStack {
                if let title = title {
                    Text(title.uppercased())
                        .font(.custom("AvenirNext-Bold", size: 16))
                        .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65))
                        .padding(.top, 2)
                    Divider()
                }
                content
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(.regularMaterial).cornerRadius(25)
        .environment(\.colorScheme, .dark)
        .font(.system(size: 18))
        .fontWeight(.bold)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 5, y: 5)
    }
}

