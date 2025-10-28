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
                    .settingsItemFont()
                Spacer()
            }
            .padding(5)
        }
    }
}

struct UserSettings: View {
    @State var selectedUser: String?
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var topBarController: TopBarController
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            SettingsList {
                // Legacy Users Section
                SettingsSection(title: "Active User") {
                    ForEach(fakeUsers, id: \.self) { user in
                        SettingsRadioItem(
                            title: user,
                            isChecked: user == selectedUser,
                            action: {
                                selectedUser = user
                            }
                        )
                    }
                    SettingsRadioItem(
                        title: "Anonymous User",
                        isChecked: selectedUser == nil,
                        action: {
                            selectedUser = nil
                        }
                    
                    )
                    UserSettingsAddUserButton(action: { print("meow")})
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alpacaListNavigationBar()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                }
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
                    TopBarMinimized(userName: .constant("alice.bsky.social"))
                        .environmentObject(NavigationCoordinator())
                    
                }
                .background(.ultraThickMaterial)
                .environment(\.colorScheme, .dark)
            }
        }.tint(Color(red: 0.75, green: 0.25, blue: 0.75))
    }
}
