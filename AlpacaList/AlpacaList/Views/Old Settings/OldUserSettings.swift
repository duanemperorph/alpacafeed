//
//  UserSettings.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/9/23.
//

import SwiftUI

struct UserSettingsSection: View {
    @State var selectedUser: String?
    
    var allUsersOptions: [String] {
        return fakeUsers + ["Anonymous User"]
    }
    
    var body: some View {
        SettingsSectionView(title: "SELECT USER") {
            VStack {
                //For each community
                ForEach(allUsersOptions, id: \.self) { user in
                    UserSettingsItem(username: user, isChecked: user == selectedUser)
                    .onTapGesture {
                        selectedUser = user
                    }
                
                    Divider()
                }
                UserSettingsAddUserButton()
            }
        }
    }
}

struct UserSettingsLogoutButton: View {
    var body: some View {
        HStack {
            // bookmark image
            Image(systemName: "arrowshape.turn.up.backward")
                .font(.system(size: 20))
                .frame(width: 20)
            Spacer().frame(width: 20)
            Text("LOGOUT")
                .font(.system(size: 18))
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: 1)
            Spacer().frame(width: 20)
        }
        .foregroundColor(.red)
        .fontWeight(.bold)
    }
}

struct UserSettingsLogoutSection: View {
    var body: some View {
        SettingsSectionView {
            UserSettingsLogoutButton()
        }
    }

}

struct OldUserSettings: View {
    var body: some View {
        ZStack {
            VStack{}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
            ScrollView {
                VStack(alignment: .center, spacing: 25) {
                    UserSettingsSection()
                    UserSettingsLogoutSection()
                }
            }
        }.safeAreaInset(edge: .top) {
            VStack {
                TopBarMinimized(communityName: "imacat@alpaca.world", icon: "gear")
            }
            .background(.thickMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}

struct OldUserSettings_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            OldUserSettings()
        }
    }
}
