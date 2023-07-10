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

struct InstanceSettingsSection: View {
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

struct FavoritesSettingsSection: View {
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

struct OldInstanceSettings: View {
    var body: some View {
        ZStack {
            VStack{}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
            ScrollView {
                VStack(alignment: .center, spacing: 25) {
                    InstanceSettingsSection()
                    FavoritesSettingsSection(title: "Favorites")
                    FavoritesSettingsSection(title: "Subscriptions")
                }
            }
        }.safeAreaInset(edge: .top) {
            VStack {
                TopBarMinimized(communityName: "lemmyworld@lemmy.world", icon: "globe")
            }
            .background(.thickMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}

struct OldInstanceSettings_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            OldInstanceSettings()
        }
    }
}
