//
//  PostComponents.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 8/6/23.
//

import SwiftUI

struct PostTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity,
                    alignment: .leading)
    }
}

struct PostUsername: View {
    let username: String
    
    var body: some View {
        Text("@\(username)")
            .frame(maxWidth: .infinity,
                    alignment: .leading)
    }
}

struct PostBody: View {
    let bodyText: String
    
    var body: some View {
        Text(bodyText)
            .frame(maxWidth: .infinity,
                    alignment: .leading)
    }
}

struct PostThumbnail: View {
    let thumbnail: String
    
    var body: some View {
        Image(thumbnail)
            .resizable()
            .scaledToFit()
    }
}
