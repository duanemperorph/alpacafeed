# App State Refactor Plan

## Architecture Overview

### Proposed Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                       API Services                          │
│  (BlueskyAPIClient, AuthService, FeedService)               │
│  - HTTP requests                                            │
│  - Codable DTOs                                             │
│  - Authentication headers                                   │
└──────────────────────────┬──────────────────────────────────┘
                           │ returns DTOs
┌──────────────────────────▼──────────────────────────────────┐
│                      Repositories                           │
│  (FeedRepository, AuthRepository, ProfileRepository)        │
│  - Business logic                                           │
│  - Caching strategy                                         │
│  - Data transformation (DTOs → Models)                      │
└──────────────────────────┬──────────────────────────────────┘
                           │ returns Models, updates state
┌──────────────────────────▼──────────────────────────────────┐
│                        AppState                             │
│  (@Observable, injected via @Environment)                   │
│  - Authentication state                                     │
│  - Current user session                                     │
│  - Global post cache                                        │
│  - Account management                                       │
└──────────────────────────┬──────────────────────────────────┘
                           │ provides access to repos & cache
┌──────────────────────────▼──────────────────────────────────┐
│                       ViewModels                            │
│  (TimelineViewModel, ThreadViewModel, ComposeViewModel)     │
│  - UI-specific logic                                        │
│  - Formatting, presentation                                 │
│  - User interactions                                        │
└──────────────────────────┬──────────────────────────────────┘
                           │ @Observable changes trigger updates
┌──────────────────────────▼──────────────────────────────────┐
│                          Views                              │
│  (TimelineView, ThreadView, ComposeView, PostCard)          │
│  - SwiftUI declarative UI                                   │
│  - Observes ViewModels                                      │
└─────────────────────────────────────────────────────────────┘
```

### App State -> View Model connector

* ViewModel factory (initalized with the app state?)
* Factory used by navigation coordinator
* App State -> Nav Coordinator (?)


### ViewModel -> View connector

* Pass in as initalizer to view

### App State Module

* Repositories
* Navigation Controller system
* ViewModel Factory

## Implementation Plan: AppState Factory Architecture

### **Phase 1: Create Repository Layer**

1. **Create `FeedRepository.swift`** (mock implementation)
   - `fetchFeed(type: TimelineType) -> [Post]`
   - `loadMore(cursor: String) -> [Post]`
   - Returns mock data directly using `MockDataGenerator`
   - In-memory cache for pagination

2. **Create `ThreadRepository.swift`** (mock implementation)
   - `fetchThread(postUri: String) -> (rootPost: Post, parents: [Post], replies: [Post])`
   - Returns mock thread data

3. **Create `PostRepository.swift`** (mock implementation)
   - `createPost(text: String, replyTo: Post?) -> Post`
   - `likePost(uri: String) -> Void`
   - `unlikePost(uri: String) -> Void`
   - `repost(uri: String) -> Void`
   - `deleteRepost(uri: String) -> Void`
   - Uses shared cache for optimistic updates

4. **Create Shared Cache Classes**
   - `PostCache.swift` - Actor for thread-safe post caching
   - `ProfileCache.swift` - Actor for author/profile caching

* Questions: should the feed / thread repos match the view model pattern or bluesky api?

---

### **Phase 2: Create AppState**

5. **Create `AppState.swift`**
   - Hold `NavigationCoordinator` instance
   - Contains repository instances
   - ViewModel factory methods:
     - `makeTimelineViewModel(type: TimelineType) -> TimelineViewModel`
     - `makeThreadViewModel(post: Post) -> ThreadViewModel`
     - `makeComposeViewModel(replyTo: Post?) -> ComposeViewModel`
   - Global state (currentUser, settings, etc.)
   - Shared cache instances

---

### **Phase 3: Refactor NavigationCoordinator**

Division of Responsibilities:

**NavigationCoordinator**
- Holds navigation state (`navigationStack`, modal flags)
- Provides navigation commands (`push()`, `pop()`, `presentCompose()`)
- No view or viewmodel knowledge

**AppState**
- Owns `NavigationCoordinator` and repositories
- Creates ViewModels with proper dependencies (factory methods)
- No view knowledge

**NavigationRootView**
- Binds `NavigationCoordinator` state to SwiftUI's `NavigationStack` API
- Creates Views from destinations
- Asks `AppState` for ViewModels

**Flow**: ViewModel calls NavigationCoordinator → State changes → SwiftUI detects change → NavigationRootView creates View → AppState provides ViewModel

| Role | Responsibility | Who |
|------|---------------|-----|
| **State Container** | Navigation state | `NavigationCoordinator` |
| **State Mutator** | Navigation commands | `NavigationCoordinator` |
| **ViewModel Factory** | Creates ViewModels with dependencies | `AppState` |
| **View Factory** | Creates Views with ViewModels | `NavigationRootView` |
| **SwiftUI Integration** | Binds to SwiftUI APIs | `NavigationRootView` |


---

### **Phase 4: Refactor ViewModels**

7. **Update `TimelineViewModel.swift`**
   - Add `init(feedRepository: FeedRepository, postRepository: PostRepository, navigationCoordinator: NavigationCoordinator, type: TimelineType)`
   - Remove mock data methods from init
   - Call repository methods instead of TODOs
   - Add navigation convenience methods:
     - `openThread(post: Post)`
     - `openProfile(handle: String)`
     - `reply(to: Post)`

8. **Update `ThreadViewModel.swift`**
   - Add `init(post: Post, threadRepository: ThreadRepository, postRepository: PostRepository, navigationCoordinator: NavigationCoordinator)`
   - Call repository methods
   - Remove static `withMockData()` method

9. **Update `ComposeViewModel.swift`**
   - Add `init(replyTo: Post?, postRepository: PostRepository, onPostCreated: (Post) -> Void)`
   - Use repository's `createPost()` method
   - Call completion handler when done

---

### **Phase 5: Update Views / Finish Wire Everything Together**

?

---

## File Structure Summary

```
AlpacaList/
├── Model/
│   ├── Data/           (existing - Post, Author, etc.)
│   ├── Mock/           (existing - MockDataGenerator)
│   ├── Repository/     (NEW)
│   │   ├── FeedRepository.swift
│   │   ├── ThreadRepository.swift
│   │   └── PostRepository.swift
│   ├── Cache/          (NEW)
│   │   ├── PostCache.swift
│   │   └── ProfileCache.swift
│   └── VM/            (existing - update all)
│       ├── TimelineViewModel.swift
│       ├── ThreadViewModel.swift
│       └── ComposeViewModel.swift
├── State/             (NEW)
│   └── AppState.swift
└── Views/
    ├── Root/
    │   └── AlpacaListApp.swift    (update)
    └── Navigation/
        ├── NavigationCoordinator.swift    (refactor)
        └── NavigationRootView.swift       (update)
```

---

## TODOs:

* User / auth related repository
    - must take into account multi-user capability