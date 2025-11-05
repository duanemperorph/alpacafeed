//
//  AlpacaListApp.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

@main
struct AlpacaListApp: App {
    @State private var navigationCoordinator = NavigationCoordinator()
    @State private var topBarController = TopBarController()
    
    var body: some Scene {
        WindowGroup {
            RootPreviews()
                .environment(navigationCoordinator)
                .environment(topBarController)
        }
    }
}
