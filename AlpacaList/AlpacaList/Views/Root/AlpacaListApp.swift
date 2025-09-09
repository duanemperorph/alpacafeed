//
//  AlpacaListApp.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import SwiftUI

@main
struct AlpacaListApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            appCoordinator.createView()
                .onAppear {
                    appCoordinator.start()
                }
        }
    }
}
