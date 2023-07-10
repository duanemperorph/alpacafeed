//
//  UserSettings.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/9/23.
//

import SwiftUI

let fakeUsers = [
    "moonlight@stellarverse.net",
    "wanderlust@dreamscape.com",
    "starrynight@cosmicrealm.io",
    "whimsical@enchantedwoods.xyz",
    "serendipity@eternalhorizon.co"
]



struct UserSettingsAddUserButton: View {
    var action: () -> Void
    
    var body: some View {
        SettingsButton(action: action) {
            HStack {
                // bookmark image
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .frame(width: 20)
                Spacer().frame(width: 20)
                Text("Add New User")
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
            }
            .padding(5)
        }
    }
}

struct UserSettings: View {
    @State var selectedUser: String?
    
    var body: some View {
        SettingsList {
            SettingsSection(title: "Change User") {
                ForEach(fakeUsers, id: \.self) { user in
                    SettingsRadioItem(
                        username: user,
                        isChecked: user == selectedUser,
                        action: {
                            selectedUser = user
                        }
                    )
                }
                SettingsRadioItem(
                    username: "Anonymous User",
                    isChecked: selectedUser == nil,
                    action: {
                        selectedUser = nil
                    }
                
                )
                UserSettingsAddUserButton(action: { print("meow")})
            }
        }
    }
}

struct UserSettings_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            UserSettings()
                .frame(width: .infinity, height: .infinity)
            .safeAreaInset(edge: .top) {
                VStack {
                    TopBarMinimized(communityName: "imacat@alpaca.world", icon: "gear")
                    
                }
                .background(.ultraThickMaterial)
                .environment(\.colorScheme, .dark)
            }
        }
    }
}
