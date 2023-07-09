//
//  TopBarInstanceSelect.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/8/23.
//

import SwiftUI

struct SettingsListViewItem: View {
    var body: some View {
        VStack {
            VStack {
                
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(.thinMaterial).cornerRadius(25)
            .environment(\.colorScheme, .dark)
            .font(.system(size: 18))
            .fontWeight(.bold)
        }.padding(10)
    }
}

struct SettingsToggleItem: View {
    var text: String
    @State var toggle = false
    
    var body: some View {
        VStack {
            HStack {
                Toggle(text, isOn: $toggle)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    .tint(Color(red: 0.75, green: 0.25, blue: 0.75))
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(.thinMaterial).cornerRadius(25)
            .environment(\.colorScheme, .dark)
            .font(.system(size: 18))
            .fontWeight(.bold)
        }
        .padding(10)
    }
}

struct TopBarInstanceSelect: View {
    var imageName: String
    @Binding var text: String
    
    var body: some View {
        VStack {
            HStack {
                Button("Back") {
                    print("cacbel ")
                }
                Spacer()
            }
            .foregroundColor(.white)
            .font(.system(size: 20))
            .fontWeight(.semibold)
            .padding(10)
            HStack(spacing: 10) {
                Image(systemName: imageName)
                    .font(.system(size: 20))
                    .frame(width: 20, height: 20)
                Text(text)
                    .font(.system(size: 18))
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer().frame(width: 20)
            }
            .foregroundColor(.white.opacity(0.75))
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 40)
            .overlay( /// apply a rounded border
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.75), lineWidth: 0.75)
            )
        }
        .padding(10)
    }
}

struct TopBarInstanceSelect_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            VStack{}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
            VStack {
                VStack {
                    TopBarInstanceSelect(
                        imageName: "chevron.down.circle",
                        text: .constant("theranch@alapcas.world"))
                }
                .background(.thickMaterial)
                .environment(\.colorScheme, .dark)
                Spacer().frame(height: 10)
                SettingsToggleItem(text: "Favorite")
                Spacer().frame(height: 0)
                SettingsToggleItem(text: "Subscribe")
                Spacer().frame(height: 0)
                SettingsListViewItem()
                Spacer()
            }
        }
    }
}
