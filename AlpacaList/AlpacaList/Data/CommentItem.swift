//
//  PostItem.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/1/23.
//

import Foundation

struct PostItem: Identifiable {
    let id = UUID()
    let thumbnail: String?
    let title: String
    let body: String
    let username: String
    let date: Date
    let children: [CommentItem]
}

struct CommentItem: Identifiable {
    let id = UUID()
    let text: String
    let username: String
    let date: Date
    let children: [CommentItem]
}
