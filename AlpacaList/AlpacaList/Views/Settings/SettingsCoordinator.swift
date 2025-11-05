//
//  SettingsCoordinator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 10/30/25.
//

import SwiftUI
import Observation

// MARK: - Settings Destination

/// Navigation destinations for the settings flow
enum SettingsDestination: Hashable {
    case addAccount
    case accountDetails(handle: String)
    // Room for future expansion:
    // case preferences
    // case about
    // case notifications
}

// MARK: - Settings Coordinator

@Observable
class SettingsCoordinator {
    var navigationPath: [SettingsDestination] = []
    
    var canPop: Bool {
        return !navigationPath.isEmpty
    }
    
    func push(_ destination: SettingsDestination) {
        navigationPath.append(destination)
    }
    
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath.removeAll()
    }
}

