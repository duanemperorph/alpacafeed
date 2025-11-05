//
//  MockDataGenerator.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 7/29/23.
//

import Foundation

class MockDataGenerator {
    // MARK: - Timeline Generation
    
    /// Generate mock Bluesky timeline
    static func generateTimeline(count: Int = 20) -> [Post] {
        var posts: [Post] = []
        
        for i in 0..<count {
            let author = mockAuthors[i % mockAuthors.count]
            let date = Date().addingTimeInterval(-Double(i * 3600)) // Posts spread over time
            
            // Mix different post types
            let post: Post
            
            switch i % 6 {
            case 0:
                // Text only post
                post = Post.createTextPost(
                    author: author,
                    text: mockPostTexts[i % mockPostTexts.count],
                    createdAt: date
                )
                
            case 1:
                // Post with image
                post = Post.createImagePost(
                    author: author,
                    text: "Check out this alpaca! 🦙",
                    images: [
                        Embed.ImageEmbed(
                            thumb: "alpaca\((i % 8) + 1)",
                            fullsize: "alpaca\((i % 8) + 1)",
                            alt: "An adorable alpaca",
                            aspectRatio: Embed.AspectRatio(width: 16, height: 9)
                        )
                    ],
                    createdAt: date
                )
                
            case 2:
                // Post with link
                post = Post(
                    uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
                    cid: "bafyrei\(UUID().uuidString.prefix(16))",
                    author: author,
                    createdAt: date,
                    text: "Interesting article about alpacas",
                    embed: .external(Embed.ExternalEmbed(
                        uri: "https://example.com/alpacas",
                        title: "The Ultimate Guide to Alpacas",
                        description: "Everything you need to know about these amazing animals",
                        thumb: "alpaca1"
                    )),
                    likeCount: Int.random(in: 0...100),
                    repostCount: Int.random(in: 0...50),
                    replyCount: Int.random(in: 0...20)
                )
                
            case 3:
                // Post with video
                post = Post(
                    uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
                    cid: "bafyrei\(UUID().uuidString.prefix(16))",
                    author: author,
                    createdAt: date,
                    text: mockVideoTexts[i % mockVideoTexts.count],
                    embed: .video(Embed.VideoEmbed(
                        thumbnail: "alpaca\((i % 8) + 1)",
                        playlist: "https://www.pexels.com/download/video/29351281/?fps=59.94&h=360&w=640",
                        alt: "Colorful alpacas in scenic Peruvian landscape",
                        aspectRatio: Embed.AspectRatio(width: 16, height: 9)
                    )),
                    likeCount: Int.random(in: 50...500),
                    repostCount: Int.random(in: 20...200),
                    replyCount: Int.random(in: 10...100)
                )
                
            case 4:
                // Post with repost attribution
                let repostedBy = mockAuthors[(i + 1) % mockAuthors.count]
                post = Post(
                    uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
                    cid: "bafyrei\(UUID().uuidString.prefix(16))",
                    author: author,
                    createdAt: date,
                    text: mockPostTexts[(i + 5) % mockPostTexts.count],
                    likeCount: Int.random(in: 0...100),
                    repostCount: Int.random(in: 0...50),
                    replyCount: Int.random(in: 0...20),
                    repostedBy: repostedBy
                )
                
            default:
                // Regular post with engagement
                post = Post(
                    uri: "at://\(author.did)/app.bsky.feed.post/\(UUID().uuidString)",
                    cid: "bafyrei\(UUID().uuidString.prefix(16))",
                    author: author,
                    createdAt: date,
                    text: mockPostTexts[i % mockPostTexts.count],
                    likeCount: Int.random(in: 0...100),
                    repostCount: Int.random(in: 0...50),
                    replyCount: Int.random(in: 0...20)
                )
            }
            
            posts.append(post)
        }
        
        return posts
    }
    
    // MARK: - Thread Reply Generation
    
    /// Generate mock thread replies
    static func generateThreadReplies(to post: Post, count: Int = 10) -> [Post] {
        var replies: [Post] = []
        
        for i in 0..<count {
            let author = mockAuthors[i % mockAuthors.count]
            let date = post.createdAt.addingTimeInterval(Double((i + 1) * 300)) // 5 min apart
            
            let reply = Post.createReply(
                author: author,
                text: mockReplyTexts[i % mockReplyTexts.count],
                replyTo: post,
                createdAt: date
            )
            
            replies.append(reply)
        }
        
        return replies
    }
}
