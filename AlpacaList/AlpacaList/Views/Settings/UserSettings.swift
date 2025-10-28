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
    @State var users: [String] = fakeUsers
    @State private var showLogoutAlert = false
    @State private var userToLogout: String?
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var topBarController: TopBarController
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            SettingsList {
                // Accounts Section
                SettingsSection(title: "Accounts") {
                    ForEach(users, id: \.self) { user in
                        AccountListItem(
                            username: user,
                            isActive: user == selectedUser,
                            onSwitch: {
                                selectedUser = user
                            },
                            onLogout: {
                                // Show confirmation alert
                                userToLogout = user
                                showLogoutAlert = true
                            }
                        )
                    }
                    
                    // Anonymous User option
                    SettingsRadioItem(
                        title: "Anonymous User",
                        isChecked: selectedUser == nil,
                        action: {
                            selectedUser = nil
                        }
                    )
                    
                    Divider()
                        .padding(.vertical, 5)
                    
                    UserSettingsAddUserButton(action: { 
                        // Handle add user - for now just print
                        print("Add new account")
                    })
                }
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 10)
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
            .alert("Log Out", isPresented: $showLogoutAlert, presenting: userToLogout) { user in
                Button("Cancel", role: .cancel) {
                    userToLogout = nil
                }
                Button("Log Out", role: .destructive) {
                    // Handle logout logic
                    if user == selectedUser {
                        selectedUser = nil // Switch to anonymous
                    }
                    // Remove user from list
                    users.removeAll { $0 == user }
                    userToLogout = nil
                }
            } message: { user in
                Text("Are you sure you want to log out of \(user)?")
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
