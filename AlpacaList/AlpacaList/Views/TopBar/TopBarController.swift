//
//  TopBarController.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 9/6/23.
//

import Foundation
import Observation

@Observable
class TopBarController {
    var isExpanded = false
    
    var topBarInset: Double {
        return isExpanded ? 90 : 40
    }
    
    func expand() {
        isExpanded = true
    }
    
    func collapse() {
        isExpanded = false
    }
}
