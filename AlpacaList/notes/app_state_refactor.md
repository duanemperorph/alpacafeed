# App State Refactor Plan

## Architecture Overview

### Current State
- Views → ViewModels (TimelineViewModel, PostViewModel, ComposeViewModel, ThreadViewModel)
- ViewModels have local state and TODO markers for API calls
- No centralized state management
- No API layer

### Proposed Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                       API Services                           │
│  (BlueskyAPIClient, AuthService, FeedService)               │
│  - HTTP requests                                             │
│  - Codable DTOs                                              │
│  - Authentication headers                                    │
└──────────────────────────┬──────────────────────────────────┘
                           │ returns DTOs
┌──────────────────────────▼──────────────────────────────────┐
│                      Repositories                            │
│  (FeedRepository, AuthRepository, ProfileRepository)        │
│  - Business logic                                            │
│  - Caching strategy                                          │
│  - Data transformation (DTOs → Models)                       │
└──────────────────────────┬──────────────────────────────────┘
                           │ returns Models, updates state
┌──────────────────────────▼──────────────────────────────────┐
│                        AppState                              │
│  (@Observable, injected via @Environment)                    │
│  - Authentication state                                      │
│  - Current user session                                      │
│  - Global post cache                                         │
│  - Account management                                        │
└──────────────────────────┬──────────────────────────────────┘
                           │ provides access to repos & cache
┌──────────────────────────▼──────────────────────────────────┐
│                       ViewModels                             │
│  (TimelineViewModel, ThreadViewModel, ComposeViewModel)     │
│  - UI-specific logic                                         │
│  - Formatting, presentation                                  │
│  - User interactions                                         │
└──────────────────────────┬──────────────────────────────────┘
                           │ @Observable changes trigger updates
┌──────────────────────────▼──────────────────────────────────┐
│                          Views                               │
│  (TimelineView, ThreadView, ComposeView, PostCard)          │
│  - SwiftUI declarative UI                                    │
│  - Observes ViewModels                                       │
└─────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. API Layer (`Model/API/`)

**Purpose:** Raw communication with Bluesky AT Protocol

**Files to create:**
- `BlueskyAPIClient.swift` - Core HTTP client with authentication
- `DTOs/` - Data Transfer Objects that match API responses
  - `TimelineDTO.swift`
  - `PostDTO.swift`
  - `AuthDTO.swift`
- `Services/`
  - `AuthService.swift` - Login, session management
  - `FeedService.swift` - Timeline, posts, threads
  - `InteractionService.swift` - Like, repost, reply
  - `ProfileService.swift` - User profiles

**Key characteristics:**
- Pure networking code
- No business logic
- Returns DTOs (not domain models)
- Throws errors for HTTP failures

### 2. Repository Layer (`Model/Repositories/`)

**Purpose:** Bridge between API and app state, handle caching

**Files to create:**
- `FeedRepository.swift` - Manages posts, timelines
- `AuthRepository.swift` - Authentication & sessions
- `ProfileRepository.swift` - User profiles
- `InteractionRepository.swift` - Likes, reposts

**Responsibilities:**
- Convert DTOs → Domain Models (Post, Author, etc.)
- Implement caching strategies
- Handle pagination cursors
- Deduplication logic
- Error handling & retry logic

**Key characteristics:**
- Business logic lives here
- Stateless (doesn't hold data, just coordinates)
- Returns domain models
- Uses API services

### 3. AppState (`Model/AppState/`)

**Purpose:** Centralized, observable application state

**Files to create:**
- `AppState.swift` - Main state container
- `AuthenticationState.swift` - Auth-specific state
- `CacheManager.swift` - In-memory post cache

**AppState structure:**
```swift
@Observable
class AppState {
    // Authentication
    var authState: AuthenticationState
    var currentUser: Author?
    var session: Session?
    
    // Cache
    private(set) var postCache: [String: Post] = [:] // keyed by URI
    
    // Repositories (injected)
    let feedRepository: FeedRepository
    let authRepository: AuthRepository
    let profileRepository: ProfileRepository
    let interactionRepository: InteractionRepository
    
    // Methods
    func login(identifier: String, password: String) async throws
    func logout() async
    func like(postUri: String) async throws
    func repost(postUri: String) async throws
    func getPost(uri: String) -> Post?
    func updatePostInCache(_ post: Post)
}
```

### 4. ViewModels (existing, but modified)

**Changes needed:**
- Inject `AppState` via `@Environment`
- Read from AppState cache
- Call AppState methods for actions
- Remain focused on presentation logic

**Example TimelineViewModel refactor:**
```swift
@Observable
class TimelineViewModel {
    private let appState: AppState
    var posts: [Post] = []
    var isLoading = false
    var error: Error?
    private var cursor: String?
    
    init(timelineType: TimelineType, appState: AppState) {
        self.timelineType = timelineType
        self.appState = appState
    }
    
    func fetchTimeline() async {
        isLoading = true
        do {
            let timeline = try await appState.feedRepository.getTimeline(
                type: timelineType, 
                cursor: nil
            )
            posts = timeline.posts
            cursor = timeline.cursor
            
            // Update cache
            timeline.posts.forEach { appState.updatePostInCache($0) }
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func likePost(uri: String) async {
        // Optimistic update
        if let index = posts.firstIndex(where: { $0.uri == uri }) {
            posts[index].isLiked.toggle()
        }
        
        do {
            try await appState.like(postUri: uri)
        } catch {
            // Revert on error
            if let index = posts.firstIndex(where: { $0.uri == uri }) {
                posts[index].isLiked.toggle()
            }
        }
    }
}
```

## Data Flow Examples

### Example 1: Fetching Timeline
```
1. User opens app
2. TimelineView appears
3. TimelineViewModel.fetchTimeline() called
4. ViewModel → AppState.feedRepository.getTimeline()
5. Repository → FeedService.getTimeline()
6. FeedService makes HTTP request to /xrpc/app.bsky.feed.getTimeline
7. Response DTOs returned
8. Repository converts DTOs → Post models
9. Repository returns Timeline(posts, cursor)
10. ViewModel updates @Observable posts array
11. View automatically re-renders
12. Posts cached in AppState.postCache
```

### Example 2: Liking a Post
```
1. User taps like button on PostCard
2. PostCard calls action in TimelineViewModel
3. ViewModel:
   a. Optimistically updates local post state (instant UI feedback)
   b. Calls appState.like(postUri)
4. AppState → interactionRepository.like(uri)
5. Repository → InteractionService.createLike()
6. API creates like record, returns like URI
7. Repository updates post in cache with likeUri
8. ViewModel receives success/failure
9. On error: ViewModel reverts optimistic update
```

### Example 3: Deep Link to Thread
```
1. User taps on post in timeline
2. NavigationCoordinator.push(.thread(post))
3. Navigation creates ThreadView with ThreadViewModel
4. ThreadViewModel:
   a. Receives post as initial data
   b. Calls appState.feedRepository.getThread(uri)
5. Repository:
   a. Fetches full thread from API
   b. Hydrates parent and replies
6. ViewModel updates posts array
7. View renders full thread
```

## Authentication Flow

### Session Management
```swift
struct Session: Codable {
    let did: String
    let handle: String
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated(Session)
    case error(Error)
}
```

### Login Flow
```
1. User enters credentials in AddAccountView
2. View calls authRepository.login(identifier, password)
3. AuthService.createSession() → /xrpc/com.atproto.server.createSession
4. On success: Session saved to AppState + Keychain
5. AppState.authState = .authenticated(session)
6. All subsequent API calls use session.accessToken
```

### Token Refresh
```
1. API call returns 401 Unauthorized
2. BlueskyAPIClient intercepts error
3. Calls AuthService.refreshSession()
4. Updates AppState.session with new tokens
5. Retries original request
```

## Cache Strategy

### Post Cache
- **When to cache:** After any fetch (timeline, thread, profile)
- **Key:** Post URI
- **Invalidation:** Time-based (e.g., 5 minutes) or manual
- **Updates:** Merge engagement counts from API

### Benefits
1. **Consistency:** Same post shown in multiple views stays in sync
2. **Performance:** Avoid redundant API calls
3. **Offline:** Show cached content when offline
4. **Optimistic updates:** Apply immediately to cache

## File Structure

```
AlpacaList/
  Model/
    Data/           (existing - domain models)
    VM/             (existing - view models, refactor to use AppState)
    
    AppState/       (NEW)
      AppState.swift
      AuthenticationState.swift
      CacheManager.swift
    
    API/            (NEW)
      BlueskyAPIClient.swift
      APIError.swift
      
      DTOs/
        TimelineDTO.swift
        PostDTO.swift
        AuthDTO.swift
        ProfileDTO.swift
      
      Services/
        AuthService.swift
        FeedService.swift
        InteractionService.swift
        ProfileService.swift
    
    Repositories/   (NEW)
      FeedRepository.swift
      AuthRepository.swift
      ProfileRepository.swift
      InteractionRepository.swift
```

## Migration Plan

### Phase 1: Foundation
1. Create API layer skeleton (BlueskyAPIClient, DTOs, Services)
2. Create Repository layer
3. Create AppState with minimal functionality

### Phase 2: Authentication
1. Implement AuthService
2. Implement AuthRepository
3. Update UserSettings to use AppState
4. Test login/logout flow

### Phase 3: Feed Display
1. Implement FeedService.getTimeline()
2. Implement FeedRepository
3. Update TimelineViewModel to use AppState
4. Replace mock data with real API calls

### Phase 4: Interactions
1. Implement InteractionService
2. Implement InteractionRepository
3. Add like/repost/reply to AppState
4. Update ViewModels to use AppState methods

### Phase 5: Advanced Features
1. Implement caching
2. Add offline support
3. Implement pagination
4. Add error handling & retry logic

## Key Principles

1. **Unidirectional Data Flow:** API → Repository → AppState → ViewModel → View
2. **Single Source of Truth:** AppState owns the data
3. **Separation of Concerns:** Each layer has clear responsibility
4. **Testability:** Each layer can be tested independently
5. **Observable Pattern:** SwiftUI @Observable for reactive updates
6. **Dependency Injection:** Pass AppState via @Environment

