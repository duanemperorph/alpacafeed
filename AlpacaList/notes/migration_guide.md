# Migration Guide: FeedItem → Post

## Quick Reference

### Property Mapping

| Old (`FeedItem`) | New (`Post`) | Notes |
|-----------------|-------------|-------|
| `id: UUID` | `id: UUID` | ✅ Same |
| `username: String` | `author: Author` | Now a full object with DID, handle, avatar, etc. |
| `date: Date` | `createdAt: Date` | ✅ Renamed but same concept |
| `title: String?` | ❌ **REMOVED** | Bluesky posts have no titles |
| `body: String?` | `text: String` | Now required, max ~300 chars |
| `thumbnail: String?` | `embed: Embed?` | Much richer: images, videos, quotes, links |
| `children: [FeedItem]` | ❌ **REMOVED** | Use `reply: ReplyRef?` instead |
| - | `uri: String` | ✅ **NEW** - AT Protocol identifier |
| - | `cid: String` | ✅ **NEW** - Content hash |
| - | `facets: [Facet]?` | ✅ **NEW** - Rich text (mentions, links, hashtags) |
| - | `reply: ReplyRef?` | ✅ **NEW** - Threading (simpler than children) |
| - | `likeCount: Int` | ✅ **NEW** - Engagement metrics |
| - | `repostCount: Int` | ✅ **NEW** - Engagement metrics |
| - | `replyCount: Int` | ✅ **NEW** - Engagement metrics |
| - | `isLiked: Bool` | ✅ **NEW** - User interaction state |
| - | `isReposted: Bool` | ✅ **NEW** - User interaction state |
| - | `repostedBy: Author?` | ✅ **NEW** - Repost attribution |

## Threading Model Changes

### Old (Reddit-style)
```swift
struct FeedItem {
    let children: [FeedItem]  // Recursive tree
}

// Access nested comments
post.children[0].children[1].children[0]  // Deep nesting
```

### New (Bluesky-style)
```swift
struct Post {
    let reply: ReplyRef?  // Just parent + root references
}

struct ReplyRef {
    let root: StrongRef    // Original post in thread
    let parent: StrongRef  // Direct parent
}

// Flat structure - threads are fetched separately
```

## Content Model Changes

### Old (Reddit-style)
```swift
FeedItem.createPost(
    id: UUID(),
    username: "alice",
    date: Date(),
    title: "Check out this alpaca!",  // ❌ Has title
    body: "Here's a cool photo...",
    thumbnail: "alpaca1.jpg",  // Simple string
    children: []
)
```

### New (Bluesky-style)
```swift
Post(
    uri: "at://did:plc:abc123/app.bsky.feed.post/xyz789",
    cid: "bafyreiabc123...",
    author: Author(
        did: "did:plc:abc123",
        handle: "alice.bsky.social",
        displayName: "Alice",
        avatar: "https://..."
    ),
    createdAt: Date(),
    text: "Check out this alpaca! 🦙",  // No title, just text
    facets: [
        // Rich text features (mentions, links, hashtags)
    ],
    embed: .images([
        Embed.ImageEmbed(
            fullsize: "https://...",
            alt: "An adorable alpaca"
        )
    ])
)
```

## Display Changes

### Title Handling
```swift
// OLD: Display title prominently, body as secondary
VStack {
    if let title = feedItem.title {
        Text(title).font(.headline)  // ❌ No longer exists
    }
    if let body = feedItem.body {
        Text(body).font(.body)
    }
}

// NEW: Display text only (no title)
VStack {
    Text(post.text).font(.body)  // Just text
}
```

### Comment Threading
```swift
// OLD: Recursive nested UI
ForEach(feedItem.children) { child in
    FeedItemView(item: child, indentation: indentation + 1)
}

// NEW: Flat list, fetch threads separately
List(replies) { reply in  // replies: [Post]
    PostCard(post: reply)  // No indentation needed
}
```

### Author Display
```swift
// OLD: Simple username
Text(feedItem.username)

// NEW: Rich author info
HStack {
    AsyncImage(url: URL(string: post.author.avatar ?? ""))
    VStack(alignment: .leading) {
        Text(post.author.displayNameOrHandle)
        Text("@\(post.author.handle)").foregroundColor(.secondary)
    }
}
```

## Factory Method Changes

### Old Methods
```swift
// ❌ Remove these
FeedItem.createPost(id:username:date:title:body:thumbnail:children:)
FeedItem.createComment(id:username:date:body:indention:children:)
```

### New Methods
```swift
// ✅ Use these
Post.createTextPost(author:text:createdAt:)
Post.createImagePost(author:text:images:createdAt:)
Post.createReply(author:text:replyTo:createdAt:)

// Or use full initializer
Post(uri:cid:author:createdAt:text:...)
```

## Migration Checklist

- [ ] Replace `FeedItem` references with `Post`
- [ ] Update username strings to `Author` objects
- [ ] Remove title display logic
- [ ] Replace `body` with `text`
- [ ] Replace thumbnail with `embed` handling
- [ ] Remove recursive children rendering
- [ ] Add engagement metrics display (likes, reposts)
- [ ] Add interaction buttons (like, repost, reply)
- [ ] Update mock data generators
- [ ] Update view models to use `Post`
- [ ] Update tests to use `Post`

## Example: Complete Migration

### Before (FeedItem)
```swift
let post = FeedItem.createPost(
    id: UUID(),
    username: "alice",
    date: Date(),
    title: "My First Post",
    body: "Hello world!",
    thumbnail: nil,
    children: [
        FeedItem.createComment(
            id: UUID(),
            username: "bob",
            date: Date(),
            body: "Great post!",
            indention: 1,
            children: []
        )
    ]
)
```

### After (Post)
```swift
let alice = Author(did: "did:plc:alice", handle: "alice.bsky.social")
let bob = Author(did: "did:plc:bob", handle: "bob.bsky.social")

let post = Post.createTextPost(
    author: alice,
    text: "My First Post\n\nHello world!"  // Combined title + body
)

let reply = Post.createReply(
    author: bob,
    text: "Great post!",
    replyTo: post
)

// Note: Replies are separate, not nested
```

