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

struct UserSettingsItemCheckMark: View {
    var isChecked: Bool
    
    var body: some View {
        // return a puruple checkmark in circle if checked
        // return a gray cicrle sybmol if not checked
        if isChecked {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.purple)
                .fontWeight(.bold)
        } else {
            Image(systemName: "circle")
                .foregroundColor(Color.primary.opacity(0.35))
                .fontWeight(.light)
        }
    }
}

struct UserSettingsItem: View {
    var username: String
    var isChecked: Bool
    
    var body: some View {
        Button(action: {}) {
            HStack {
                // bookmark image
                UserSettingsItemCheckMark(isChecked: isChecked)
                    .font(.system(size: 20))
                    .frame(width: 20)
                Spacer().frame(width: 20)
                Text(username)
                    .font(.system(size: 18))
                    .lineLimit(1)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(5)
        }
    }
}

struct UserSettingsAddUserButton: View {
    // add a tap gesture that handles the start / end events
    var gesture: some Gesture {
        return DragGesture(minimumDistance: 0)
            .onChanged { _ in
                print("started")
            }
            .onEnded { _ in
                print("ended")
            }
    }
    
    var body: some View {
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
        .gesture(gesture)
    }
}

struct SettingsHeader: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 16))
            .fontWeight(.semibold)
            .fontDesign(.monospaced)
            .foregroundColor(Color.primary.opacity(0.5))
    }
}

struct UserSettings: View {
    @State var selectedUser: String?
    
    var body: some View {
        List {
            Section(header: SettingsHeader(title: "Change User")) {
                ForEach(fakeUsers, id: \.self) { user in
                    UserSettingsItem(username: user,
                                     isChecked: user == selectedUser)
                    .gesture(TapGesture()
                                .onEnded { _ in
                                    selectedUser = user
                                })
                }
                UserSettingsItem(username: "Anonymous User", isChecked: selectedUser == nil)
                    .gesture(TapGesture()
                        .onEnded { _ in
                            selectedUser = nil
                        })
                UserSettingsAddUserButton()
                    .simultaneousGesture(TapGesture()
                        .onEnded { _ in
                            print("new")
                        })
            }
            .listRowBackground(
                Color.clear.background(.thinMaterial)
            )
            .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        }
        .scrollContentBackground(.hidden)
        .listStyle(InsetGroupedListStyle())
        .background(.ultraThinMaterial)
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
