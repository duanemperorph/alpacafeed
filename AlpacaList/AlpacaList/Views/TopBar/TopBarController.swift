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
        return isExpanded ? 170 : 80
    }
    
    func expand() {
        isExpanded = true
    }
    
    func collapse() {
        isExpanded = false
    }
}
