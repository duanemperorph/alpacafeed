//
//  TopBarInstanceSelect.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/8/23.
//

import SwiftUI

let fakeCommunities = [
    "m/CatConspiracy",
    "m/PotatoFashion",
    "m/CheeseArt",
    "m/UnicornLoversAnonymous",
    "m/InvisiblePetschallenges",
    "m/TinfoilCraftshats",
    "m/SockDrawerMysteriesof",
    "m/BananaGangdiscussions",
    "m/UnderwaterBasketWeavin",
    "m/AvocadoJuggling"
]

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
            .padding(.vertical, 10)
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

struct InstanceSettingsItem: View {
    @State var favorited = false
    @State var subscribed = false
    
    var body: some View {
        SettingsSectionView(title: "Instance Settings") {
            VStack {
                Toggle("Favorite", isOn: $favorited)
                    .tint(Color(red: 0.75, green: 0.25, blue: 0.75))
                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                Toggle("Subscribe", isOn: $subscribed)
                    .tint(Color(red: 0.75, green: 0.25, blue: 0.75))
                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
            }
        }
    }
}

struct FavoritesSettingsItem: View {
    var title: String
    
    var body: some View {
        SettingsSectionView(title: title) {
            VStack {
                //For each community
                ForEach(fakeCommunities, id: \.self) { community in
                    HStack {
                        // bookmark image
                        Image(systemName: "bookmark")
                            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                            .font(.system(size: 16))
                        Spacer().frame(width: 20)
                        Text(community)
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                        Spacer()
                    }.padding(5)
                    
                    if community != fakeCommunities.last {
                        Divider()
                    }
                }
            }
        }
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
            ScrollView {
                VStack(alignment: .center, spacing: 25) {
                    InstanceSettingsItem()
                    FavoritesSettingsItem(title: "Favorites")
                    FavoritesSettingsItem(title: "Subscriptions")
                }
            }
        }.safeAreaInset(edge: .top) {
            VStack {
                TopBarInstanceSelect(
                    imageName: "chevron.down.circle",
                    text: .constant("theranch@alapcas.world"))
            }
            .background(.thickMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}
