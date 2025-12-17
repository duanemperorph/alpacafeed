//
//  UserSettings.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/9/23.
//

import SwiftUI

struct UserSettingsLoginButton: View {
    var action: () -> Void
    
    var body: some View {
        SettingsButton(action: action) {
            HStack {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .frame(width: 20)
                Spacer().frame(width: 20)
                Text("Sign In")
                    .settingsItemFont()
                Spacer()
            }
            .padding(5)
        }
    }
}

struct UserSettings: View {
    @State private var showLogoutAlert = false
    @State private var settingsCoordinator = SettingsCoordinator()
    @Environment(AppState.self) private var appState
    @Environment(NavigationCoordinator.self) private var navigationCoordinator
    @Environment(TopBarController.self) private var topBarController
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var settingsCoordinator = settingsCoordinator
        NavigationStack(path: $settingsCoordinator.navigationPath) {
            SettingsList {
                // Account Section
                SettingsSection(title: "Account") {
                    if appState.isAuthenticated, let handle = appState.authRepository.currentHandle {
                        // Show logged-in user
                        AccountListItem(
                            username: handle,
                            isActive: true,
                            onSwitch: { },
                            onLogout: {
                                showLogoutAlert = true
                            }
                        )
                    } else {
                        // Show sign in option
                        UserSettingsLoginButton(action: {
                            settingsCoordinator.push(.addAccount)
                        })
                    }
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
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    Task {
                        await appState.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .addAccount:
                    AddAccountView(
                        onLoginSuccess: {
                            settingsCoordinator.pop()
                        },
                        onCancel: {
                            settingsCoordinator.pop()
                        }
                    )
                case .accountDetails(let handle):
                    // Placeholder for future account details view
                    Text("Account details for \(handle)")
                }
            }
        }
    }
}

struct UserSettings_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let navigationCoordinator = NavigationCoordinator(appState: appState)
        let topBarController = TopBarController()
        
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            UserSettings()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environment(appState)
                .environment(navigationCoordinator)
                .environment(topBarController)
        }
        .tint(Color(red: 0.75, green: 0.25, blue: 0.75))
    }
}
