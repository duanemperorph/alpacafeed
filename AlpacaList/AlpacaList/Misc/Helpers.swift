//
//  Helpers.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/27/23.
//

import Foundation
import SwiftUI

protocol RecursiveIdentifiable<RecursiveID>: Identifiable where ID == RecursiveID {
    associatedtype RecursiveID: Hashable
    
    var children: [Self] { get }
}

extension Array where Element: RecursiveIdentifiable {
    typealias IdType = Element.RecursiveID
    
    func recursiveFindItem(withId: IdType) -> Element? {
        for item in self {
            if item.id == withId {
                return item
            }
            
            if let child = item.children.recursiveFindItem(withId: withId) {
                return child
            }
        }
        return nil
    }
}

// MARK: - View Modifiers

/// Applies consistent AlpacaList chrome styling to navigation bars
struct AlpacaListNavigationBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.regularMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    /// Applies the standard AlpacaList navigation bar styling
    /// - Regular material background with dark color scheme
    /// - Use with `.foregroundColor(.white)` on toolbar buttons
    func alpacaListNavigationBar() -> some View {
        modifier(AlpacaListNavigationBarStyle())
    }
}
