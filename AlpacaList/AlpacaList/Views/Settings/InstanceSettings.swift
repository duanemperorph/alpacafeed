//
//  InstanceSettings.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/16/23.
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

struct InstanceSettingsBookmarkItem: View {
    var title: String
    
    var body: some View {
        HStack {
            // bookmark image
            Image(systemName: "bookmark")
                .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                .font(.system(size: 16))
            Spacer().frame(width: 20)
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 18))
            Spacer()
        }.padding(5)
    }
}

struct InstanceSettingsListItem: View {
    var title: String
    
    var body: some View {
        SettingsButton (action: {
            //
        }) {
            HStack {
                // bookmark image
                Image(systemName: "bookmark")
                    .settingsItemFont()
                Spacer().frame(width: 20)
                Text(title)
                    .settingsItemFont()
                Spacer()
                Image(systemName: "chevron.right")
                    .settingsItemFont()
            }.padding(5)
        }
    }
}

struct InstanceSettingsBookmarksSection: View {
    var title: String
    
    var body: some View {
        SettingsSection(title: title) {
            ForEach(fakeCommunities, id: \.self) { community in
                InstanceSettingsListItem(title: community)
            }
        }
    }
}

struct InstanceSettingsOptionsSection: View {
    @State var isFavorite = false
    @State var isSubscribed = false
    
    var body: some View {
        SettingsSection(title: "OPTIONS") {
            SettingsToggleItem(title: "Favorite", isChecked: $isFavorite)
            SettingsToggleItem(title: "Subscribed", isChecked: $isSubscribed)
        }
    }
}

struct InstanceSettings: View {
    var body: some View {
        SettingsList {
            InstanceSettingsOptionsSection()
            InstanceSettingsBookmarksSection(title: "Bookmarks")
            InstanceSettingsBookmarksSection(title: "Favorites")
        }
    }
}

struct InstanceSettings_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            InstanceSettings()
                .frame(width: .infinity, height: .infinity)
            .safeAreaInset(edge: .top) {
                VStack {
                    TopBarMinimized(communityName: "imacat@alpaca.world", icon: "gear")
                    
                }
                .background(.ultraThickMaterial)
                .environment(\.colorScheme, .dark)
            }
        }.tint(Color(red: 0.75, green: 0.25, blue: 0.75))
    }
}
