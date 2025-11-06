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
    @State private var navigationCoordinator: NavigationCoordinator
    @State private var topBarController = TopBarController()
    
    init() {
        let appState = AppState()
        self._appState = State(initialValue: appState)
        self._navigationCoordinator = State(initialValue: NavigationCoordinator(appState: appState))
        self._topBarController = State(initialValue: TopBarController())
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationRootView(navigationCoordinator: navigationCoordinator)
                .environment(appState)
                .environment(topBarController)
        }
    }
}
