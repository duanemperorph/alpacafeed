//
//  Helpers.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/27/23.
//

import Foundation

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
