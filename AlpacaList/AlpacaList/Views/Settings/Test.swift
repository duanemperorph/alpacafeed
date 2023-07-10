//
//  Test.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/9/23.
//

import SwiftUI

struct Test: View {
    var body: some View {
        List {
            Button(action: {
                print("tapped")
            }) {
                Text("Test")
                    .font(.system(size: 18))
                    .lineLimit(1)
                    .fontWeight(.medium)
            }
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
