# View Model Migration Guide

## Quick Reference: Old → New View Models

### PostsListViewModel → TimelineViewModel

```swift
// OLD
class PostsListViewModel {
    let rootPostItems: [FeedItem]
    let posts: [FeedItemViewModel]
    
    init(rootPosts: [FeedItem])
    func getCommentsViewModelForPost(withId: UUID) -> CommentsListViewModel?
    static func withMockData() -> PostsListViewModel
}

// NEW
class TimelineViewModel: ObservableObject {
    @Published var posts: [Post]
    @Published var isLoading: Bool
    
    init(timelineType: TimelineType = .home)
    func fetchTimeline()
    func loadMore()
    func refresh() async
    
    // Interactions
    func likePost(uri: String)
    func repost(uri: String)
    func quotePost(uri: String, text: String)
    func deletePost(uri: String)
    func toggleBookmark(uri: String)
    
    static func withMockData() -> TimelineViewModel
}
```

**Key Changes:**
- ✅ Added `@Published` properties for reactivity
- ✅ Added pagination (`cursor`, `loadMore()`)
- ✅ Added interaction methods
- ✅ Added timeline types (home, profile, custom)
- ✅ Posts array is now `[Post]` instead of `[FeedItemViewModel]`
- ❌ Removed comment navigation (handled separately)

---

### CommentsListViewModel → ThreadViewModel

```swift
// OLD
class CommentsListViewModel: ObservableObject {
    let postItem: FeedItem
    let postViewModel: FeedItemViewModel
    var comments: [FeedItemViewModel]
    @Published var visibleComments: [FeedItemViewModel]
    @Published private(set) var expandedIds: Set<UUID>
    
    init(post: FeedItem)
    func isExpanded(id: UUID) -> Bool
    func toggleExpanded(id: UUID)
    private func flatten(items: [FeedItemViewModel], expandedIds: Set<UUID>) -> [FeedItemViewModel]
    var postWithComments: [FeedItemViewModel]
}

// NEW
class ThreadViewModel: ObservableObject {
    @Published var rootPost: Post?
    @Published var parentPosts: [Post]
    @Published var replies: [Post]
    @Published var isLoading: Bool
    
    init(postUri: String)
    init(post: Post)
    
    func fetchThread(depth: Int = 6)
    func fetchMoreReplies()
    func refresh() async
    
    // Interactions
    func likePost(uri: String)
    func repost(uri: String)
    func reply(to uri: String, text: String)
    func deletePost(uri: String)
    
    var allPosts: [Post]  // Computed: parents + root + replies
    var isReplyThread: Bool
}
```

**Key Changes:**
- ✅ Three-part structure (parents + root + replies) vs nested tree
- ✅ No expand/collapse logic needed
- ✅ No flattening algorithm needed
- ✅ Added parent context chain
- ✅ Added interaction methods
- ✅ Simpler state management
- ❌ Removed `expandedIds` Set
- ❌ Removed recursive flattening

---

### FeedItemViewModel → PostViewModel

```swift
// OLD
class FeedItemViewModel: ObservableObject, Identifiable {
    let style: FeedItemStyle  // .post or .comment
    let indention: Int
    let feedItem: FeedItem
    let children: [FeedItemViewModel]
    
    var id: UUID { feedItem.id }
    
    init(commentItem: FeedItem, style: FeedItemStyle, indention: Int = 0)
}

// NEW
class PostViewModel: ObservableObject, Identifiable {
    let post: Post
    
    var id: UUID { post.id }
    
    // Display helpers
    var formattedDate: String
    var fullFormattedDate: String
    var displayText: String
    
    // Content checks
    var hasMedia: Bool
    var isQuotePost: Bool
    var hasExternalLink: Bool
    var isReply: Bool
    var isRepost: Bool
    
    // Engagement formatting
    var formattedLikeCount: String
    var formattedRepostCount: String
    var formattedReplyCount: String
    var formattedQuoteCount: String
    var totalEngagement: Int
    
    // Author helpers
    var authorDisplayName: String
    var authorHandle: String
    var authorHandleWithAt: String
    var repostedByText: String?
    
    // Embed helpers
    var imageEmbeds: [Embed.ImageEmbed]?
    var videoEmbed: Embed.VideoEmbed?
    var externalEmbed: Embed.ExternalEmbed?
    var quoteEmbed: Embed.RecordEmbed?
    
    // Rich text parsing
    func parseTextSegments() -> [TextSegment]
    
    init(post: Post)
}
```

**Key Changes:**
- ✅ Much richer display helpers
- ✅ Engagement count formatting
- ✅ Author display helpers
- ✅ Embed access helpers
- ✅ Rich text parsing foundation
- ❌ Removed `style` enum
- ❌ Removed `indention` property
- ❌ Removed `children` array

---

## Usage Examples

### Displaying a Timeline

```swift
// OLD
let postsVM = PostsListViewModel(rootPosts: mockData)
List(postsVM.posts) { postVM in
    FeedItemView(item: postVM)
}

// NEW
let timelineVM = TimelineViewModel()
List(timelineVM.posts) { post in
    PostCard(post: post)
}
.refreshable {
    await timelineVM.refresh()
}
```

### Displaying a Thread

```swift
// OLD
let commentsVM = CommentsListViewModel(post: selectedPost)
List(commentsVM.postWithComments) { commentVM in
    FeedItemView(item: commentVM)
}

// NEW
let threadVM = ThreadViewModel(post: selectedPost)
List(threadVM.allPosts) { post in
    PostCard(post: post, isMainPost: post.id == threadVM.rootPost?.id)
}
```

### Displaying a Post

```swift
// OLD
struct FeedItemView: View {
    let item: FeedItemViewModel
    
    var body: some View {
        if item.style == .post {
            // Show title + body
            if let title = item.feedItem.title {
                Text(title).font(.headline)
            }
            if let body = item.feedItem.body {
                Text(body)
            }
        } else {
            // Show comment (indented)
            Text(item.feedItem.body ?? "")
                .padding(.leading, CGFloat(item.indention * 20))
        }
    }
}

// NEW
struct PostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading) {
            // Author header
            AuthorHeader(author: post.author, date: post.createdAt)
            
            // Text content (no title/body distinction)
            Text(post.text)
            
            // Embeds
            if let embed = post.embed {
                PostEmbed(embed: embed)
            }
            
            // Engagement bar
            EngagementBar(
                likeCount: post.likeCount,
                repostCount: post.repostCount,
                replyCount: post.replyCount,
                isLiked: post.isLiked,
                isReposted: post.isReposted
            )
        }
        // No indentation needed
    }
}
```

### Interactions

```swift
// OLD - No built-in interactions
// Had to implement separately in views

// NEW - Built into view models
Button("Like") {
    timelineVM.likePost(uri: post.uri)
}

Button("Repost") {
    timelineVM.repost(uri: post.uri)
}

Button("Reply") {
    threadVM.reply(to: post.uri, text: replyText)
}
```

---

## Migration Checklist

### For Timeline Views
- [ ] Replace `PostsListViewModel` with `TimelineViewModel`
- [ ] Change `posts: [FeedItemViewModel]` to `posts: [Post]`
- [ ] Add pull-to-refresh using `refresh()` async
- [ ] Add infinite scroll using `loadMore()`
- [ ] Wire up interaction buttons to view model methods
- [ ] Update mock data usage to `TimelineViewModel.withMockData()`

### For Thread Views
- [ ] Replace `CommentsListViewModel` with `ThreadViewModel`
- [ ] Remove expand/collapse UI (`toggleExpanded`)
- [ ] Change from `postWithComments` to `allPosts`
- [ ] Add parent context display for `parentPosts`
- [ ] Highlight main post (`rootPost`) differently from replies
- [ ] Remove indentation logic
- [ ] Wire up reply functionality

### For Post Display
- [ ] Replace `FeedItemViewModel` with `PostViewModel` (or use `Post` directly)
- [ ] Remove style-based rendering (`.post` vs `.comment`)
- [ ] Remove indentation logic
- [ ] Use post formatting helpers (`formattedDate`, `formattedLikeCount`, etc.)
- [ ] Add author display with avatar/handle
- [ ] Add embed rendering
- [ ] Add engagement buttons

---

## Testing Migration

```swift
// OLD
let postsVM = PostsListViewModel.withMockData()
let commentsVM = CommentsListViewModel.withMockData()

// NEW
let timelineVM = TimelineViewModel.withMockData()
let threadVM = ThreadViewModel.withMockData()
let postVM = PostViewModel(post: timelineVM.posts[0])
```

All mock data constructors still work and provide realistic test data!

