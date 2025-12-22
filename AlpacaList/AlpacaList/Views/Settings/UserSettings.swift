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
                Text("Add Account")
                    .settingsItemFont()
                Spacer()
            }
            .padding(5)
        }
    }
}

struct UserSettings: View {
    @State private var showLogoutAlert = false
    @State private var accountToLogout: AuthSession? = nil
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
                SettingsSection(title: "Accounts") {
                    // Show all logged-in accounts
                    ForEach(appState.allAccounts) { account in
                        AccountListItem(
                            username: account.handle,
                            isActive: appState.isActiveAccount(did: account.did),
                            onSwitch: {
                                Task {
                                    await appState.switchAccount(to: account.did)
                                }
                            },
                            onLogout: {
                                accountToLogout = account
                                showLogoutAlert = true
                            }
                        )
                    }
                    
                    // Add Account button (always shown)
                    UserSettingsLoginButton(action: {
                        settingsCoordinator.push(.addAccount)
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
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {
                    accountToLogout = nil
                }
                Button("Log Out", role: .destructive) {
                    if let account = accountToLogout {
                        Task {
                            await appState.logout(did: account.did)
                        }
                    }
                    accountToLogout = nil
                }
            } message: {
                if let account = accountToLogout {
                    Text("Are you sure you want to log out of @\(account.handle)?")
                } else {
                    Text("Are you sure you want to log out?")
                }
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
