//
//  AlpacaListApp.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

@main
struct AlpacaListApp: App {
    @State private var appState = AppState()
    @State private var topBarController = TopBarController()
    
    var body: some Scene {
        WindowGroup {
            NavigationRootView()
                .environment(appState)
                .environment(topBarController)
                .task {
                    await appState.restoreSession()
                }
        }
    }
}
