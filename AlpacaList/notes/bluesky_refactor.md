I'll help you plan a refactor from a Reddit-style forum to a Bluesky-style micro-blogging system. Let me first examine the current codebase structure and your Bluesky API notes to create a comprehensive plan.

[10 tools called]

Based on my analysis of your codebase and Bluesky API documentation, here's a comprehensive refactoring plan to transition from a Reddit-style forum to a Bluesky-style micro-blogging system:

## **Refactoring Plan: Reddit → Bluesky Micro-blogging**

### **Phase 1: Data Model Transformation**

#### **1.1 Core Post Model (`FeedItem.swift` → `Post.swift`)**

**Current Reddit-style structure:**
- Has `title` field (posts have titles)
- Hierarchical `children` (deeply nested comment trees)
- Distinction between "posts" and "comments"

**New Bluesky-style structure:**
```swift
struct Post: Identifiable {
    // AT Protocol identifiers
    let uri: String          // at:// URI
    let cid: String          // Content identifier
    let id: UUID            
    
    // Author info
    let author: Author       // handle, displayName, avatar
    let createdAt: Date
    
    // Content (no title - just text)
    let text: String         // Max 300 chars
    let facets: [Facet]?     // Rich text (mentions, links, hashtags)
    let embed: Embed?        // Images, videos, quoted posts, external links
    
    // Threading (simpler than Reddit)
    let reply: ReplyRef?     // Parent and root post references
    
    // Engagement metrics
    let likeCount: Int
    let repostCount: Int
    let replyCount: Int
    
    // User interaction state
    var isLiked: Bool
    var isReposted: Bool
    var isBookmarked: Bool
    
    // For reposts
    let repostedBy: Author?  // If this appears in timeline as a repost
}
```

**Key Changes:**
- **Remove:** `title` field (Bluesky has no post titles)
- **Remove:** Deep `children` hierarchy (Bluesky uses simpler reply chains)
- **Add:** AT Protocol identifiers (`uri`, `cid`)
- **Add:** Engagement metrics and interaction states
- **Add:** Rich content support (`facets`, `embed`)
- **Add:** Repost functionality
- **Simplify:** Threading model (just parent/root references, not full tree)

#### **1.2 Supporting Models**

Create new models:
- `Author.swift` - User profile info (handle, displayName, avatar)
- `Facet.swift` - Rich text features (mentions, links, hashtags)
- `Embed.swift` - Media and quoted posts
- `ReplyRef.swift` - Parent and root post references
- `Timeline.swift` - Feed container with cursor pagination

---

### **Phase 2: View Model Refactoring**

#### **2.1 Timeline ViewModel (replaces `PostsListViewModel`)**

**From:** List of root posts with nested comments
**To:** Reverse-chronological timeline feed

```swift
class TimelineViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    private var cursor: String?
    
    // Fetch methods
    func fetchTimeline()        // Home feed
    func fetchAuthorFeed(handle: String)  // Profile feed
    func fetchCustomFeed(uri: String)     // Algorithm feed
    func loadMore()             // Pagination
    
    // Interactions
    func likePost(uri: String)
    func repost(uri: String)
    func quotePost(uri: String, text: String)
    func deleteRepost(uri: String)
}
```

#### **2.2 Thread ViewModel (replaces `CommentsListViewModel`)**

**From:** Complex nested tree with expand/collapse
**To:** Linear thread view with parent context

```swift
class ThreadViewModel: ObservableObject {
    @Published var rootPost: Post?
    @Published var parentPosts: [Post] = []  // Chain to root
    @Published var replies: [Post] = []      // Direct replies only
    
    func fetchThread(uri: String)
    func fetchMoreReplies()
}
```

**Key Changes:**
- Remove complex tree flattening logic
- Remove expand/collapse state management
- Simpler linear display

#### **2.3 Post ViewModel (replaces `FeedItemViewModel`)**

**From:** Wrapper with style (post/comment) and indentation
**To:** Unified post view model

```swift
class PostViewModel: ObservableObject, Identifiable {
    let post: Post
    
    // Display helpers
    var formattedDate: String
    var displayText: String  // With facets applied
    var hasMedia: Bool
    var isQuotePost: Bool
    
    // No more: style, indention, children hierarchy
}
```

---

### **Phase 3: UI Components Refactoring**

#### **3.1 Unified Post Card (replaces `FeedItemView`)**

**Remove:**
- `PostTitle` component (no titles in Bluesky)
- Post vs Comment distinction
- Indentation logic

**Create:**
```swift
struct PostCard: View {
    let post: Post
    let onLike: () -> Void
    let onRepost: () -> Void
    let onReply: () -> Void
    
    // Displays:
    // - Author header (avatar, display name, handle, timestamp)
    // - Reposted by indicator (if applicable)
    // - Post text with rich text facets
    // - Embedded media/quote post
    // - Engagement buttons (like, repost, reply)
    // - Engagement counts
}
```

#### **3.2 New Components Needed**

1. **`AuthorHeader.swift`**
   - Avatar, display name, handle, timestamp
   - Reposted by indicator

2. **`RichTextView.swift`**
   - Renders text with facets (clickable mentions, links, hashtags)

3. **`PostEmbed.swift`**
   - Images/videos
   - Quoted posts
   - External link previews

4. **`EngagementBar.swift`**
   - Like/repost/reply buttons with counts
   - Replace `PostItemButtons` and `CommentItemButtons`

5. **`QuotePostCard.swift`**
   - Embedded post display within another post

#### **3.3 Feed Views**

**Replace:**
- `PostsFeedView` → `TimelineView`
- `CommentsFeedView` → `ThreadView`

```swift
struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    
    // Displays:
    // - Vertical scrolling list of posts
    // - Pull to refresh
    // - Infinite scroll pagination
    // - No nested comments, just posts
}

struct ThreadView: View {
    @ObservedObject var viewModel: ThreadViewModel
    
    // Displays:
    // - Parent posts (context chain)
    // - Main post (highlighted)
    // - Direct replies (linear list, not tree)
    // - "Load more replies" button
}
```

---

### **Phase 4: Navigation & Architecture**

#### **4.1 Navigation Updates**

Update `NavigationCoordinator`:
```swift
enum NavigationDestination {
    case timeline                    // Home feed
    case profile(handle: String)     // User profile + posts
    case thread(uri: String)         // Post thread
    case customFeed(uri: String)     // Algorithm feed
    case compose(replyTo: Post?)     // New post/reply
    case quotePost(post: Post)       // Quote post composer
}
```

#### **4.2 Settings Updates**

Update settings to support:
- Multiple Bluesky accounts
- Custom feed preferences
- Timeline algorithm selection
- Content filtering

---

### **Phase 5: Mock Data Updates**

Update `MockDataGenerator.swift`:
```swift
class MockDataGenerator {
    // Replace generatePosts() with:
    static func generateTimeline() -> [Post]
    static func generateThread() -> (Post, [Post])  // root + replies
    static func generateQuotePost() -> Post
    
    // New mock data:
    static let mockAuthors: [Author]
    static let mockPostTexts: [String]  // Short, tweet-like
    static let mockEmbeds: [Embed]
    static let mockFacets: [Facet]
}
```

---

### **Phase 6: Feature Additions**

#### **6.1 Core Interactions**

Implement action handlers:
- Like/unlike posts
- Repost/undo repost
- Quote post (repost with comment)
- Reply to posts
- Delete own posts

#### **6.2 Rich Content**

Implement:
- **Facet parsing:** Detect and link mentions, hashtags, URLs
- **Media display:** Images, videos, GIFs
- **Quote posts:** Embedded post display
- **Link previews:** External website cards

#### **6.3 API Integration Layer**

Create `BlueskyAPI.swift`:
```swift
class BlueskyAPI {
    // Feed endpoints
    func getTimeline(cursor: String?) async throws -> Timeline
    func getAuthorFeed(handle: String) async throws -> Timeline
    func getPostThread(uri: String) async throws -> Thread
    
    // Interaction endpoints
    func createPost(text: String, reply: ReplyRef?) async throws
    func likePost(uri: String) async throws
    func repost(uri: String) async throws
    func deletePost(uri: String) async throws
}
```

---

### **Phase 7: Testing Updates**

Update tests:
- Remove tests for nested comment expansion
- Add tests for timeline pagination
- Add tests for engagement interactions
- Update UI tests for new navigation flow

---

## **Migration Strategy**

### **Recommended Order:**

1. **Start with Data Models** (Phase 1)
   - Create new `Post.swift` and supporting models
   - Keep old `FeedItem.swift` temporarily for comparison

2. **Update Mock Data** (Phase 5)
   - Create Bluesky-style mock data
   - Easier to test UI without API

3. **Refactor Core Components** (Phase 3.1-3.2)
   - Build new `PostCard` with mock data
   - Test in isolation

4. **Update View Models** (Phase 2)
   - Implement new timeline/thread logic
   - Connect to mock data

5. **Rebuild Views** (Phase 3.3)
   - Create timeline and thread views
   - Wire up navigation

6. **Add Interactions** (Phase 6.1)
   - Like, repost, reply handlers
   - Initially with local state only

7. **Rich Content** (Phase 6.2)
   - Facets, embeds, media

8. **API Integration** (Phase 6.3)
   - Connect to real Bluesky API
   - Replace mock data

9. **Testing & Polish** (Phase 7)
   - Update test suite
   - UI polish

---

## **Key Architectural Differences**

| **Aspect** | **Reddit-style (Current)** | **Bluesky-style (Target)** |
|------------|---------------------------|---------------------------|
| **Post Structure** | Title + Body | Text only (no title) |
| **Threading** | Deep nested trees | Shallow reply chains |
| **Content Length** | Unlimited | ~300 characters |
| **Rich Content** | Thumbnails only | Images, videos, quote posts, facets |
| **Interactions** | View comments | Like, repost, reply |
| **Feed Types** | Single subreddit-style | Timeline, profiles, custom algorithms |
| **Navigation** | Post → Comments thread | Timeline → Thread view |
| **Comment UI** | Indented tree with expand/collapse | Linear list of replies |

---

This plan transforms your app from a discussion-focused platform (Reddit) to a conversational micro-blogging platform (Bluesky). Would you like me to start implementing any specific phase of this refactoring plan?