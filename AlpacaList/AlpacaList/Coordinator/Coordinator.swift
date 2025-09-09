//
//  Coordinator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on [date]
//

import SwiftUI

protocol Coordinator: ObservableObject {
    associatedtype ContentView: View
    
    /// The child coordinators managed by this coordinator
    var childCoordinators: [any Coordinator] { get set }
    
    /// The parent coordinator (if any)
    var parent: (any Coordinator)? { get set }
    
    /// Start the coordinator
    func start()
    
    /// Create the main view for this coordinator
    func createView() -> ContentView
    
    /// Add a child coordinator
    func addChild(_ coordinator: any Coordinator)
    
    /// Remove a child coordinator
    func removeChild(_ coordinator: any Coordinator)
    
    /// Finish this coordinator and clean up
    func finish()
}

extension Coordinator {
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.parent = self
    }
    
    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { existing in
            return ObjectIdentifier(existing) == ObjectIdentifier(coordinator)
        }
    }
    
    func finish() {
        parent?.removeChild(self)
    }
} 