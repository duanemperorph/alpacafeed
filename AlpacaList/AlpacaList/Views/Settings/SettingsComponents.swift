//
//  SettingsComponents.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/9/23.
//

import SwiftUI

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
    
    @State var isTouching = false
    
    var touchGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({_ in
                isTouching = true
            })
            .onEnded({_ in
                isTouching = false
            })
    }
    
    var tapGesture: some Gesture {
        TapGesture()
            .onEnded({_ in
                action()
            })
    }
    
    var body: some View {
        contents
            .foregroundColor(isTouching ? .primary.opacity(0.5) : .primary)
            .gesture(touchGesture)
            .simultaneousGesture(tapGesture)
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
    var username: String
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
                Text(username)
                    .font(.system(size: 18))
                    .lineLimit(1)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(5)
        }
    }
}

struct SettingsToggleItem: View {
    var title: String
    var isChecked: Bool
    
    var body: some View {
        return VStack{}
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
