[5 tools called]

Now I have a complete picture. Here's the integration plan:

---

## Bluesky API Integration Plan

### Current Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Views                                 │
│   TimelineView, ThreadView, ComposeView                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     ViewModels                               │
│   TimelineViewModel, ThreadViewModel, ComposeViewModel      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Repositories                              │
│   FeedRepository, ThreadRepository, PostRepository          │
│   ⚠️ Currently using MockDataGenerator                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       Caches                                 │
│   PostCache, ProfileCache                                   │
└─────────────────────────────────────────────────────────────┘
```

### Target Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Repositories                              │
│   FeedRepository, ThreadRepository, PostRepository          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      FeedService                             │
│   getTimeline(), getPostThread(), likePost(), etc.          │
│   + Mappers: API types → App models                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      BSAPIClient                             │
│   Authenticated requests, token refresh                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     ATProtoClient                            │
│   HTTP, URL building, error handling                        │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 1: Dependency Wiring

**Goal:** Get `FeedService` accessible from repositories

| Task | Location | Description |
|------|----------|-------------|
| 1.1 | `AppState` | Add `feedService: FeedService` property |
| 1.2 | `AppState` | Create `BSAPIClient` with `authRepository` |
| 1.3 | `ViewModelFactory` | Accept `FeedService` and pass to repositories |
| 1.4 | Repositories | Add `FeedService` as constructor parameter |

---

### Phase 2: API Response Mappers

**Goal:** Convert API types to app models

| Mapper | From | To |
|--------|------|----|
| `AuthorView` → `Author` | `FeedService.swift` | `Author.swift` |
| `PostView` → `Post` | `FeedService.swift` | `Post.swift` |
| `FeedViewPost` → `Post` | (includes repost context) | |
| `ThreadViewPost` → `[Post]` | (flatten parent chain + replies) | |

**Location:** New file `Model/API/ResponseMappers.swift` or extensions on app models

**Key mappings:**
```
PostView.author          → Post.author (via AuthorView → Author)
PostView.record.text     → Post.text
PostView.record.createdAt → Post.createdAt (parse ISO8601)
PostView.viewer?.like    → Post.isLiked (non-nil = liked)
PostView.viewer?.repost  → Post.isReposted
PostView.viewer?.like    → Post.likeUri (for unlike)
FeedViewPost.reason      → Post.repostedBy (if repost)
```

---

### Phase 3: Repository Integration

**Goal:** Replace mock data with API calls

#### 3.1 FeedRepository

| Method | Current | Target |
|--------|---------|--------|
| `fetchFeed()` | `MockDataGenerator.generateTimeline()` | `feedService.getTimeline()` |
| `loadMore()` | Mock data | `feedService.getTimeline(cursor:)` |

```swift
// FeedRepository.fetchFeed()
let response = try await feedService.getTimeline(cursor: nil, limit: limit)
let posts = response.feed.map { mapFeedViewPost($0) }
await postCache.cachePosts(posts)
self.postUris = posts.map { $0.uri }
self.cursor = response.cursor
```

#### 3.2 ThreadRepository

| Method | Current | Target |
|--------|---------|--------|
| `fetchThread()` | Mock replies | `feedService.getPostThread(uri:)` |

```swift
// ThreadRepository.fetchThread()
let response = try await feedService.getPostThread(uri: postUri, depth: currentDepth)
let (rootPost, parents, replies) = flattenThread(response.thread)
// Cache and store...
```

#### 3.3 PostRepository

| Method | Current | Target |
|--------|---------|--------|
| `likePost()` | Optimistic only | `feedService.likePost()` + update `likeUri` |
| `unlikePost()` | Optimistic only | `feedService.unlikePost(likeUri:)` |
| `repost()` | Optimistic only | `feedService.repost()` + update `repostUri` |
| `deleteRepost()` | Optimistic only | `feedService.deleteRepost(repostUri:)` |
| `createPost()` | Mock | `feedService.createPost()` |
| `deletePost()` | Mock | `feedService.deletePost()` |

---

### Phase 4: Error Handling

| Error Type | Handling |
|------------|----------|
| Network error | Show error state in UI, allow retry |
| 401 Unauthorized | `BSAPIClient` auto-refreshes token |
| Rate limited | Show message, respect `retryAfter` |
| Post not found | Show "deleted" state |

---

### Phase 5: Additional API Endpoints (Future)

| Feature | Endpoint |
|---------|----------|
| Author feed | `app.bsky.feed.getAuthorFeed` |
| Likes list | `app.bsky.feed.getActorLikes` |
| Search | `app.bsky.feed.searchPosts` |
| Notifications | `app.bsky.notification.listNotifications` |
| Profile | `app.bsky.actor.getProfile` |

---

### Execution Order

1. **Phase 1** — Wire dependencies (no behavior change yet)
2. **Phase 2** — Add mappers (can unit test in isolation)
3. **Phase 3.1** — FeedRepository (home timeline works)
4. **Phase 3.2** — ThreadRepository (threads work)
5. **Phase 3.3** — PostRepository (interactions work)
6. **Phase 4** — Error handling polish

---
