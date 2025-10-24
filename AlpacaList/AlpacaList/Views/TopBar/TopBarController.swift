//
//  TopBarController.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/6/23.
//

import Foundation

class TopBarController: ObservableObject {
    @Published var isExpanded = false
    
    var topBarInset: Double {
        return isExpanded ? 130 : 40
    }
    
    func expand() {
        isExpanded = true
    }
    
    func collapse() {
        isExpanded = false
    }
}
