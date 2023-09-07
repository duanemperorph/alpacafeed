//
//  TopBarController.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/6/23.
//

import Foundation

class TopBarController: ObservableObject {
    @Published var isExpanded = false
    
    func expand() {
        isExpanded = true
    }
    
    func collapse() {
        isExpanded = false
    }
}
