//
//  SettingsComponents.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/9/23.
//

import SwiftUI

extension View {
    func settingsItemFont() -> some View {
        return self
            .font(.system(size: 18))
            .lineLimit(1)
            .fontWeight(.medium)
            .fontDesign(.monospaced)
    }
}

struct SettingsHeader: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 16))
            .fontWeight(.semibold)
            .fontDesign(.monospaced)
            .foregroundColor(Color.primary.opacity(0.6))
    }
}

struct SettingsButton<ContentView: View>: View {
    var action: () -> Void
    @ViewBuilder var contents: ContentView
    
    var body: some View {
        Button(action: action) {
            contents
        }
        .tint(.primary)
        .buttonStyle(.borderless)
    }
}

struct SettingsRadioItemCheckMark: View {
    var isChecked: Bool
    
    var body: some View {
        // return a puruple checkmark in circle if checked
        // return a gray cicrle sybmol if not checked
        if isChecked {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentColor)
                .fontWeight(.bold)
        } else {
            Image(systemName: "circle")
                .foregroundColor(Color.primary.opacity(0.35))
                .fontWeight(.light)
        }
    }
}

struct SettingsRadioItem: View {
    var title: String
    var isChecked: Bool
    var action: () -> Void
    
    var body: some View {
        SettingsButton(action: action) {
            HStack {
                // bookmark image
                SettingsRadioItemCheckMark(isChecked: isChecked)
                    .font(.system(size: 20))
                    .frame(width: 20)
                Spacer().frame(width: 20)
                Text(title)
                    .settingsItemFont()
                Spacer()
            }
            .padding(5)
        }
    }
}

struct SettingsToggleItem: View {
    var title: String
    @Binding var isChecked: Bool
    
    var body: some View {
        return VStack{
            HStack {
                Toggle(title, isOn: $isChecked)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    .settingsItemFont()
                
            }
            .padding(5)
        
        }
    }
}

struct SettingsSection<ContentsView: View>: View {
    var title: String
    @ViewBuilder var contents: ContentsView
    
    var body: some View {
        Section(header: SettingsHeader(title: title)) {
            contents
        }
        .listRowBackground(
            Color.clear.background(.thinMaterial)
        )
        .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
    }
}

struct SettingsList<ContentsView: View>: View {
    @ViewBuilder var contents: ContentsView
    
    var body: some View {
        List {
            contents
        }
        .scrollContentBackground(.hidden)
        .listStyle(InsetGroupedListStyle())
        .background(.ultraThinMaterial)
    }
}

struct AccountListItem: View {
    var username: String
    var isActive: Bool
    var onSwitch: () -> Void
    var onLogout: () -> Void
    
    var body: some View {
        SettingsButton(action: onSwitch) {
            HStack {
                SettingsRadioItemCheckMark(isChecked: isActive)
                    .font(.system(size: 20))
                    .frame(width: 20)
                Spacer().frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text(username)
                        .settingsItemFont()
                    if isActive {
                        Text("Active")
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .foregroundColor(.accentColor.opacity(0.8))
                    }
                }
                Spacer()
            }
            .padding(5)
            .contentShape(Rectangle())
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                onLogout()
            } label: {
                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .tint(.red)
        }
        .contextMenu {
            if !isActive {
                Button {
                    onSwitch()
                } label: {
                    Label("Switch to this account", systemImage: "arrow.left.arrow.right")
                }
            }
            Button(role: .destructive) {
                onLogout()
            } label: {
                Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }
}
