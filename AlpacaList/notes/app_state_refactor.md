Let me examine your app structure to understand the current state management approach:

[6 tools called]

Based on your current architecture, here's the **ideal approach for application-wide state** in a SwiftUI app like yours:

## Recommended Architecture

### 1. **Create an `AppState` ViewModel** (New file in `Model/VM/`)

This should live at the **root level** and manage:
- Authentication state (current user, tokens)
- User accounts list
- Global app settings
- Session state
- Cached data (bookmarks, drafts)

```swift
// AlpacaList/Model/VM/AppState.swift
import Foundation
import Combine

/// Global application state manager
class AppState: ObservableObject {
    // MARK: - Authentication
    @Published var currentUser: Author?
    @Published var isAuthenticated: Bool = false
    @Published var accounts: [UserAccount] = []
    
    // MARK: - Session
    @Published var sessionToken: String?
    @Published var refreshToken: String?
    
    // MARK: - User Preferences
    @Published var preferredFeedUri: String?
    @Published var hasSeenOnboarding: Bool = false
    
    // MARK: - Cached Data
    @Published var bookmarkedPosts: Set<String> = []  // Post URIs
    @Published var mutedUsers: Set<String> = []       // User DIDs
    @Published var blockedUsers: Set<String> = []     // User DIDs
    
    // MARK: - Private
    private var cancellables = Set<AnyCancellable>()
    private let persistenceManager: PersistenceManager
    
    init(persistenceManager: PersistenceManager = .shared) {
        self.persistenceManager = persistenceManager
        loadPersistedState()
        observeChanges()
    }
    
    // MARK: - Public Methods
    
    func login(user: Author, sessionToken: String, refreshToken: String) {
        self.currentUser = user
        self.sessionToken = sessionToken
        self.refreshToken = refreshToken
        self.isAuthenticated = true
        
        // Add to accounts if not already present
        if !accounts.contains(where: { $0.did == user.did }) {
            accounts.append(UserAccount(author: user))
        }
    }
    
    func logout() {
        currentUser = nil
        sessionToken = nil
        refreshToken = nil
        isAuthenticated = false
    }
    
    func switchAccount(to did: String) {
        guard let account = accounts.first(where: { $0.did == did }) else { return }
        // Load account's tokens and set as current
        // TODO: Implement token retrieval from keychain
    }
    
    func toggleBookmark(postUri: String) {
        if bookmarkedPosts.contains(postUri) {
            bookmarkedPosts.remove(postUri)
        } else {
            bookmarkedPosts.insert(postUri)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPersistedState() {
        // Load from UserDefaults/Keychain
        self.hasSeenOnboarding = persistenceManager.hasSeenOnboarding
        self.bookmarkedPosts = persistenceManager.bookmarkedPosts
        self.accounts = persistenceManager.loadAccounts()
        
        // Load last active account
        if let lastDID = persistenceManager.lastActiveAccountDID,
           let account = accounts.first(where: { $0.did == lastDID }) {
            // Restore session
            // TODO: Validate token and restore currentUser
        }
    }
    
    private func observeChanges() {
        // Auto-persist changes
        $bookmarkedPosts
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] bookmarks in
                self?.persistenceManager.saveBookmarks(bookmarks)
            }
            .store(in: &cancellables)
        
        $currentUser
            .sink { [weak self] user in
                if let did = user?.did {
                    self?.persistenceManager.setLastActiveAccount(did)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Supporting Types

struct UserAccount: Identifiable, Codable {
    let id: UUID
    let did: String
    let handle: String
    let displayName: String?
    let avatar: String?
    
    init(author: Author) {
        self.id = author.id
        self.did = author.did
        self.handle = author.handle
        self.displayName = author.displayName
        self.avatar = author.avatar
    }
}
```

---

### 2. **Inject at App Entry Point**

Update your `AlpacaListApp.swift`:

```swift
@main
struct AlpacaListApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootPreviews()
                .environmentObject(appState)
        }
    }
}
```

---

### 3. **Update RootPreviews to Accept AppState**

Modify your `RootPreviews.swift`:

```swift
struct RootPreviews: View {
    let mockFeedItems: [FeedItem]
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @StateObject private var topBarController = TopBarController()
    // AppState is injected from parent (AlpacaListApp)
    
    // ... existing init ...
    
    var body: some View {
        NavigationRootView()
            .environmentObject(navigationCoordinator)
            .environmentObject(topBarController)
            // appState is passed through from AlpacaListApp
    }
}
```

---

### 4. **Refactor UserSettings to Use AppState**

Your `UserSettings.swift` currently manages accounts with `@State` — this should be moved to `AppState`:

```swift
struct UserSettings: View {
    @EnvironmentObject var appState: AppState  // Use global state
    @StateObject private var settingsCoordinator = SettingsCoordinator()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var topBarController: TopBarController
    @Environment(\.dismiss) private var dismiss
    
    @State private var showLogoutAlert = false
    @State private var userToLogout: String?
    
    var body: some View {
        NavigationStack(path: $settingsCoordinator.navigationPath) {
            SettingsList {
                // Accounts Section
                SettingsSection(title: "Accounts") {
                    ForEach(appState.accounts) { account in
                        AccountListItem(
                            username: account.handle,
                            isActive: account.did == appState.currentUser?.did,
                            onSwitch: {
                                appState.switchAccount(to: account.did)
                            },
                            onLogout: {
                                userToLogout = account.did
                                showLogoutAlert = true
                            }
                        )
                    }
                    
                    // ... rest of the view
                }
            }
        }
    }
}
```

---

## Architecture Hierarchy

```
AlpacaListApp (@main)
├── AppState (@StateObject)                    ← GLOBAL APP STATE
│   ├── Authentication (current user, tokens)
│   ├── Accounts management
│   ├── User preferences
│   └── Cached data (bookmarks, etc.)
│
└── RootPreviews
    ├── NavigationCoordinator (@StateObject)   ← NAVIGATION STATE
    │   └── Sheet presentation
    │
    ├── TopBarController (@StateObject)        ← UI STATE
    │   └── Expand/collapse state
    │
    └── NavigationRootView
        └── TimelineViewModel (@StateObject)   ← FEATURE STATE
            └── Posts, loading, etc.
```

---

## Best Practices for Your App

1. **AppState** = Authentication, accounts, global settings, bookmarks
2. **NavigationCoordinator** = Navigation stack, sheet presentation
3. **TopBarController** = UI-specific transient state
4. **Feature ViewModels** = Feature-specific data and business logic

5. **Persistence Layer** - Create `PersistenceManager` to handle:
   - UserDefaults for preferences
   - Keychain for tokens
   - FileManager for cached data

6. **Access Pattern**:
   ```swift
   // Any view can access global state
   @EnvironmentObject var appState: AppState
   
   // Check auth
   if appState.isAuthenticated {
       // Show authenticated content
   }
   
   // Toggle bookmark
   appState.toggleBookmark(postUri: post.uri)
   ```

---

This approach gives you:
- ✅ **Single source of truth** for app-wide state
- ✅ **Testable** (can inject mock AppState)
- ✅ **Persistent** (auto-saves changes)
- ✅ **Reactive** (SwiftUI auto-updates when state changes)
- ✅ **Scoped** (feature state stays in feature ViewModels)

Would you like me to show you how to implement the `PersistenceManager` as well?

----------------------------------------------------------------------------------------------------

[2 tools called]

Based on your notes, I see you've already explored the **centralized AppState approach**. Here are several alternative architectural patterns for SwiftUI state management:

## Alternative Approaches

### 1. **The Elm/Redux Architecture** (Unidirectional Data Flow)

```swift
// Single source of truth with explicit actions
struct AppState {
    var currentUser: Author?
    var timeline: [Post] = []
    var bookmarks: Set<String> = []
}

enum AppAction {
    case login(Author, String)
    case logout
    case addPost(Post)
    case toggleBookmark(String)
}

class Store: ObservableObject {
    @Published private(set) var state = AppState()
    
    func dispatch(_ action: AppAction) {
        state = reduce(state, action)
        performSideEffects(for: action)
    }
    
    private func reduce(_ state: AppState, _ action: AppAction) -> AppState {
        var newState = state
        switch action {
        case .login(let user, let token):
            newState.currentUser = user
        case .logout:
            newState.currentUser = nil
            newState.timeline = []
        case .toggleBookmark(let uri):
            if newState.bookmarks.contains(uri) {
                newState.bookmarks.remove(uri)
            } else {
                newState.bookmarks.insert(uri)
            }
        // ... other cases
        }
        return newState
    }
}
```

**Pros**: Predictable, time-travel debugging, easy to test
**Cons**: Verbose, overkill for simple apps, learning curve

---

### 2. **Service Layer + Dependency Injection**

```swift
// Services hold business logic, not state
protocol AuthService {
    func login(handle: String, password: String) async throws -> Author
    func logout() async throws
    var currentUser: Author? { get }
}

protocol TimelineService {
    func fetchTimeline() async throws -> [Post]
    func likePost(uri: String) async throws
}

// Views use services directly, no global state
struct TimelineView: View {
    @StateObject private var viewModel: TimelineViewModel
    
    init(timelineService: TimelineService, authService: AuthService) {
        _viewModel = StateObject(wrappedValue: 
            TimelineViewModel(timelineService: timelineService, authService: authService)
        )
    }
}

// Inject at app level
@main
struct AlpacaListApp: App {
    let authService: AuthService = BlueskyAuthService()
    let timelineService: TimelineService = BlueskyTimelineService()
    
    var body: some Scene {
        WindowGroup {
            TimelineView(timelineService: timelineService, authService: authService)
        }
    }
}
```

**Pros**: Clean separation, testable with mocks, no global state
**Cons**: Manual dependency passing, harder to share state across screens

---

### 3. **Actor-Based Concurrency** (Modern Swift)

```swift
// Thread-safe state management with Swift actors
actor AppStateActor {
    private var currentUser: Author?
    private var bookmarks: Set<String> = []
    
    func login(user: Author) {
        currentUser = user
    }
    
    func toggleBookmark(_ uri: String) {
        if bookmarks.contains(uri) {
            bookmarks.remove(uri)
        } else {
            bookmarks.insert(uri)
        }
    }
    
    func isBookmarked(_ uri: String) -> Bool {
        bookmarks.contains(uri)
    }
}

// Observable wrapper for SwiftUI
@MainActor
class AppState: ObservableObject {
    @Published var currentUser: Author?
    @Published var bookmarks: Set<String> = []
    
    private let actor = AppStateActor()
    
    func login(user: Author) async {
        await actor.login(user: user)
        currentUser = user
    }
    
    func toggleBookmark(_ uri: String) async {
        await actor.toggleBookmark(uri)
        bookmarks = await actor.bookmarks
    }
}
```

**Pros**: Thread-safe by design, modern Swift patterns
**Cons**: More complex, mixing actors with ObservableObject can be tricky

---

### 4. **Composite Pattern** (Multiple Specialized Managers)

```swift
// Split concerns into specialized managers
class AuthManager: ObservableObject {
    @Published var currentUser: Author?
    @Published var isAuthenticated: Bool = false
}

class BookmarkManager: ObservableObject {
    @Published var bookmarkedPosts: Set<String> = []
    
    func toggle(_ uri: String) {
        bookmarkedPosts.insert(uri) // or remove
    }
}

class FeedManager: ObservableObject {
    @Published var activeFeed: String = "home"
    @Published var customFeeds: [String] = []
}

// Inject each separately
struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @EnvironmentObject var feedManager: FeedManager
}

@main
struct AlpacaListApp: App {
    @StateObject var auth = AuthManager()
    @StateObject var bookmarks = BookmarkManager()
    @StateObject var feeds = FeedManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(bookmarks)
                .environmentObject(feeds)
        }
    }
}
```

**Pros**: Granular control, easier to reason about, smaller classes
**Cons**: More environment objects, coordination between managers can be messy

---

### 5. **Observable Macro** (iOS 17+, Modern Approach)

```swift
import Observation

// New @Observable macro replaces ObservableObject
@Observable
class AppState {
    var currentUser: Author?
    var bookmarks: Set<String> = []
    var timeline: [Post] = []
    
    func login(user: Author) {
        currentUser = user
    }
}

// No need for @EnvironmentObject, use @Environment
struct TimelineView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        List(appState.timeline) { post in
            PostCard(post: post)
        }
    }
}

@main
struct AlpacaListApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
```

**Pros**: Cleaner syntax, better performance, less boilerplate
**Cons**: Requires iOS 17+, different mental model from Combine

---

### 6. **Hybrid: Scoped State + Shared Services**

```swift
// Lightweight global state for only truly global things
class SharedServices {
    static let shared = SharedServices()
    let apiClient = BlueskyAPIClient()
    let persistence = PersistenceManager()
}

// Feature-scoped state managers
class TimelineViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private let services = SharedServices.shared
    
    func fetchPosts() async {
        posts = try? await services.apiClient.fetchTimeline()
    }
}

// Only inject what you need
struct TimelineView: View {
    @StateObject private var viewModel = TimelineViewModel()
    @AppStorage("userDID") private var userDID: String?
    
    var body: some View {
        List(viewModel.posts) { post in
            PostCard(post: post)
        }
    }
}
```

**Pros**: Minimal global state, features stay independent, simple
**Cons**: Singleton pattern, harder to mock services, less reactive

---

## Recommendation Matrix

| Pattern | Best For | Complexity | Testability |
|---------|----------|------------|-------------|
| **Centralized AppState** | Medium apps, clear ownership | Medium | High |
| **Redux/Elm** | Complex state, time-travel debugging | High | Very High |
| **Service Layer** | Clean architecture purists | Medium-High | Very High |
| **Actor-Based** | Heavy concurrency, thread safety | High | High |
| **Composite Managers** | Domain-driven design | Low-Medium | High |
| **@Observable** | Modern iOS 17+ apps | Low | High |
| **Hybrid** | Simple apps, pragmatic approach | Low | Medium |

For **your specific app** (Bluesky client with auth, feeds, bookmarks), I'd recommend:

**Option A**: **Composite Managers** (AuthManager + BookmarkManager + FeedManager) — keeps concerns separated, easy to understand
**Option B**: **@Observable** if targeting iOS 17+ — most modern, performant approach
**Option C**: Your documented **AppState approach** — solid middle ground, good for medium complexity

Would you like me to elaborate on any of these patterns for your specific use case?

-----------------------------

I'll read the app state refactor document to understand the differences between option B and option C.

[1 tool called]

Based on the document, here's the key difference between **Option B** and **Option C**:

## Option B: @Observable Macro (iOS 17+)

This is the **modern Swift approach** using the new `@Observable` macro:

```598:598:/Users/lucasnguyen/projects/alpacafeed/AlpacaList/notes/app_state_refactor.md
**Option B**: **@Observable** if targeting iOS 17+ — most modern, performant approach
```

**Key characteristics:**
- Uses the new `@Observable` macro instead of `ObservableObject`
- Uses `@Environment` instead of `@EnvironmentObject`
- Uses `@State` instead of `@StateObject` at the app level
- **Cleaner syntax** - no need for `@Published` wrappers
- **Better performance** - more efficient change tracking
- **Less boilerplate** code
- **Requires iOS 17+**

## Option C: AppState with ObservableObject

This is the **traditional centralized state** approach:

```598:598:/Users/lucasnguyen/projects/alpacafeed/AlpacaList/notes/app_state_refactor.md
**Option C**: Your documented **AppState approach** — solid middle ground, good for medium complexity
```

**Key characteristics:**
- Uses `ObservableObject` protocol (older approach)
- Uses `@Published` property wrappers for reactive properties
- Uses `@StateObject` and `@EnvironmentObject`
- Works with **iOS 13+** (wider compatibility)
- More verbose but well-established pattern
- Better community support and documentation

---

## Main Differences

| Aspect | Option B (@Observable) | Option C (AppState/ObservableObject) |
|--------|------------------------|--------------------------------------|
| **iOS Version** | iOS 17+ only | iOS 13+ |
| **Syntax** | Cleaner, less boilerplate | More verbose with @Published |
| **Performance** | More efficient | Slightly less efficient |
| **Maturity** | Newer, less docs | Well-established |
| **Property Wrappers** | `@Environment`, `@State` | `@EnvironmentObject`, `@StateObject` |

The **practical choice** depends on your deployment target. If you're targeting iOS 17+, Option B is more modern and performant. If you need to support older iOS versions, Option C is your only choice.

-------------------------------

[3 tools called]

Beyond syntax, there are **fundamental architectural and runtime differences** between Option B (@Observable) and Option C (ObservableObject):

## 1. **Change Tracking Mechanism**

**Option C (ObservableObject + @Published)**:
- Uses **Combine framework** for reactive updates
- Every `@Published` property creates a separate `Publisher`
- When ANY `@Published` property changes, it sends an `objectWillChange` notification
- **Broadcasts to ALL observers**, even if they don't use the changed property
- Views re-render even if they only read unrelated properties

**Option B (@Observable)**:
- Uses Swift's new **Observation framework** (compile-time macro expansion)
- Tracks **which specific properties each view actually reads**
- Only notifies views that depend on the changed property
- **Fine-grained observation** - more surgical updates

**Real-world impact:**
```swift
// Option C: If you change appState.bookmarks, 
// EVERY view using appState rerenders, even if they only read currentUser

// Option B: Only views that actually access bookmarks rerender
```

---

## 2. **Memory & Performance**

**Option C:**
- Creates `AnyCancellable` objects for each subscription
- Requires manual `cancellables` management (line 44, 111, 119 in your code)
- More memory overhead from Combine infrastructure
- **Eager evaluation** - all publishers are active

**Option B:**
- No Combine overhead or cancellables needed
- Compiler-generated observation code is more efficient
- **Lazy evaluation** - only tracks what's actually being observed
- Lower memory footprint

---

## 3. **Reactive Patterns & Side Effects**

This is a **major architectural difference**:

**Option C (with Combine):**
```swift
private func observeChanges() {
    // You can create reactive pipelines
    $bookmarkedPosts
        .debounce(for: 0.5, scheduler: RunLoop.main)
        .sink { [weak self] bookmarks in
            self?.persistenceManager.saveBookmarks(bookmarks)
        }
        .store(in: &cancellables)
}
```
- **Built-in reactive programming** with operators (debounce, map, filter, etc.)
- Easy to chain transformations
- Great for complex side effects and async flows

**Option B (@Observable):**
```swift
var bookmarks: Set<String> = [] {
    didSet {
        // Manual side effects - no built-in reactive operators
        Task {
            persistenceManager.saveBookmarks(bookmarks)
        }
    }
}
```
- **No reactive operators** - you handle side effects manually
- More explicit but less powerful for complex flows
- Need to implement your own debouncing/throttling

---

## 4. **View Invalidation Strategy**

**Option C:**
- SwiftUI subscribes to `objectWillChange` publisher
- **Whole object invalidation** - changing one property invalidates the entire object
- Can cause unnecessary view updates

**Option B:**
- Compiler tracks property access at build time
- **Per-property invalidation** - only invalidates affected views
- More efficient SwiftUI updates

Example:
```swift
struct ProfileView: View {
    @EnvironmentObject var appState: AppState  // Option C
    
    var body: some View {
        Text(appState.currentUser?.handle ?? "")
        // ❌ Rerenders if bookmarks, tokens, or ANY property changes
    }
}

struct ProfileView: View {
    @Environment(AppState.self) private var appState  // Option B
    
    var body: some View {
        Text(appState.currentUser?.handle ?? "")
        // ✅ Only rerenders if currentUser changes
    }
}
```

---

## 5. **Threading & Concurrency**

**Option C:**
- Combine publishers handle thread hopping
- Built-in `receive(on:)` for thread switching
- Works well with `@MainActor` but requires manual coordination

**Option B:**
- Simpler model - just regular Swift code
- Works more naturally with Swift Concurrency (async/await)
- Less cognitive overhead with threading

---

## 6. **Testing Implications**

**Option C:**
```swift
// Testing reactive pipelines
let appState = AppState()
let expectation = XCTestExpectation()
appState.$currentUser
    .sink { user in
        expectation.fulfill()
    }
    .store(in: &cancellables)
```
- Can test reactive flows with Combine testing tools
- More complex test setup

**Option B:**
```swift
// Simpler testing
let appState = AppState()
appState.currentUser = mockUser
XCTAssertEqual(appState.currentUser, mockUser)
```
- More straightforward testing
- Less infrastructure needed

---

## **Bottom Line**

The **fundamental difference** is:

- **Option C** = Combine-based reactive programming model with broad invalidation
- **Option B** = Compiler-assisted fine-grained observation without reactive operators

If you **rely on Combine's reactive operators** (debounce, combineLatest, map chains, etc.) like in lines 104-120 of your AppState, **Option C is more powerful**.

If you want **maximum performance and cleaner code** without complex reactive flows, **Option B is superior**.

For your Bluesky app with the persistence auto-save pattern using `.debounce()`, **Option C might actually be better** unless you want to rewrite that logic manually.

--------------------

Let me elaborate on the **reactive patterns and side effects** difference between the two approaches with detailed examples:

## 2. Reactive Patterns & Side Effects (Deep Dive)

### The Core Philosophy Difference

**Option C (Combine)** is built around **Functional Reactive Programming (FRP)** - treating data changes as streams you can transform, combine, and react to declaratively.

**Option B (@Observable)** is **imperative** - you explicitly handle what happens when data changes.

---

### Example 1: Debouncing User Input

**Scenario:** Save bookmarks to disk, but not on every single change (too many writes). Wait until user stops for 0.5 seconds.

**Option C (Combine) - Declarative:**
```swift
class AppState: ObservableObject {
    @Published var bookmarkedPosts: Set<String> = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Declarative reactive pipeline
        $bookmarkedPosts
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] bookmarks in
                self?.persistenceManager.saveBookmarks(bookmarks)
            }
            .store(in: &cancellables)
    }
}

// Usage: Just set the value, debouncing happens automatically
appState.bookmarkedPosts.insert("post1")  // Not saved yet
appState.bookmarkedPosts.insert("post2")  // Not saved yet  
appState.bookmarkedPosts.insert("post3")  // Not saved yet
// ... 0.5 seconds later → Saved once with all changes
```

**Option B (@Observable) - Manual:**
```swift
import Observation

@Observable
class AppState {
    var bookmarkedPosts: Set<String> = [] {
        didSet {
            // Need to manually implement debouncing
            debouncedSave()
        }
    }
    
    private var saveTask: Task<Void, Never>?
    
    private func debouncedSave() {
        // Cancel previous save attempt
        saveTask?.cancel()
        
        // Schedule new save after delay
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(0.5))
            guard let self = self, !Task.isCancelled else { return }
            await self.persistenceManager.saveBookmarks(self.bookmarkedPosts)
        }
    }
}
```

**Winner: Option C** - built-in `.debounce()` is cleaner

---

### Example 2: Combining Multiple Properties

**Scenario:** Enable "Post" button only when user has entered text AND selected an image AND is authenticated.

**Option C (Combine):**
```swift
class ComposeViewModel: ObservableObject {
    @Published var postText: String = ""
    @Published var selectedImage: UIImage?
    @Published var isAuthenticated: Bool = false
    @Published var canPost: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Automatically compute derived state
        Publishers.CombineLatest3($postText, $selectedImage, $isAuthenticated)
            .map { text, image, auth in
                !text.isEmpty && image != nil && auth
            }
            .assign(to: &$canPost)
    }
}

// Usage: Just modify any property, canPost updates automatically
viewModel.postText = "Hello!"       // canPost updates
viewModel.selectedImage = someImage // canPost updates  
viewModel.isAuthenticated = true    // canPost updates
```

**Option B (@Observable):**
```swift
@Observable
class ComposeViewModel {
    var postText: String = "" {
        didSet { updateCanPost() }
    }
    var selectedImage: UIImage? {
        didSet { updateCanPost() }
    }
    var isAuthenticated: Bool = false {
        didSet { updateCanPost() }
    }
    var canPost: Bool = false
    
    private func updateCanPost() {
        canPost = !postText.isEmpty && selectedImage != nil && isAuthenticated
    }
}

// OR use computed property (better for this case):
@Observable
class ComposeViewModel {
    var postText: String = ""
    var selectedImage: UIImage?
    var isAuthenticated: Bool = false
    
    var canPost: Bool {
        !postText.isEmpty && selectedImage != nil && isAuthenticated
    }
}
```

**Winner: Option B (computed property)** - simpler for derived state. Option C is over-engineered here.

---

### Example 3: Chaining Async Operations

**Scenario:** When user logs in → fetch their profile → load their preferences → update UI.

**Option C (Combine):**
```swift
class AppState: ObservableObject {
    @Published var currentUser: Author?
    @Published var userProfile: Profile?
    @Published var preferences: Preferences?
    
    private var cancellables = Set<AnyCancellable>()
    
    func login(did: String, token: String) {
        // Reactive chain
        apiClient.authenticate(did: did, token: token)
            .flatMap { user in
                self.currentUser = user
                return self.apiClient.fetchProfile(did: user.did)
            }
            .flatMap { profile in
                self.userProfile = profile
                return self.apiClient.fetchPreferences(did: profile.did)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Login failed: \(error)")
                    }
                },
                receiveValue: { [weak self] prefs in
                    self?.preferences = prefs
                }
            )
            .store(in: &cancellables)
    }
}
```

**Option B (@Observable):**
```swift
@Observable
class AppState {
    var currentUser: Author?
    var userProfile: Profile?
    var preferences: Preferences?
    
    func login(did: String, token: String) async throws {
        // Sequential async/await
        let user = try await apiClient.authenticate(did: did, token: token)
        currentUser = user
        
        let profile = try await apiClient.fetchProfile(did: user.did)
        userProfile = profile
        
        let prefs = try await apiClient.fetchPreferences(did: profile.did)
        preferences = prefs
    }
}

// Usage
Task {
    do {
        try await appState.login(did: "...", token: "...")
    } catch {
        print("Login failed: \(error)")
    }
}
```

**Winner: Option B** - async/await is more readable than Combine chains for sequential operations

---

### Example 4: Reacting to Multiple Changes

**Scenario:** Auto-save draft post whenever title OR content OR images change, but also mark as "dirty" immediately.

**Option C (Combine):**
```swift
class ComposeViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var images: [UIImage] = []
    @Published var isDirty: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Track ANY change to mark as dirty immediately
        Publishers.Merge3(
            $title.map { _ in () },
            $content.map { _ in () },
            $images.map { _ in () }
        )
        .sink { [weak self] in
            self?.isDirty = true
        }
        .store(in: &cancellables)
        
        // Debounced save on ANY change
        Publishers.CombineLatest3($title, $content, $images)
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
            .sink { [weak self] title, content, images in
                self?.saveDraft(title: title, content: content, images: images)
            }
            .store(in: &cancellables)
    }
    
    private func saveDraft(title: String, content: String, images: [UIImage]) {
        // Save to persistence
        isDirty = false
    }
}
```

**Option B (@Observable):**
```swift
@Observable
class ComposeViewModel {
    var title: String = "" {
        didSet { handleContentChange() }
    }
    var content: String = "" {
        didSet { handleContentChange() }
    }
    var images: [UIImage] = [] {
        didSet { handleContentChange() }
    }
    var isDirty: Bool = false
    
    private var saveTask: Task<Void, Never>?
    
    private func handleContentChange() {
        // Mark dirty immediately
        isDirty = true
        
        // Debounce save
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.0))
            guard let self = self, !Task.isCancelled else { return }
            await self.saveDraft()
        }
    }
    
    private func saveDraft() async {
        // Save to persistence
        await persistenceManager.saveDraft(
            title: title,
            content: content, 
            images: images
        )
        isDirty = false
    }
}
```

**Winner: Option C** - cleaner separation between immediate and debounced side effects

---

### Example 5: Transforming Data Streams

**Scenario:** Display character count as user types, with color changes at thresholds.

**Option C (Combine):**
```swift
class ComposeViewModel: ObservableObject {
    @Published var postText: String = ""
    @Published var characterCount: Int = 0
    @Published var countColor: Color = .primary
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Transform text → count
        $postText
            .map { $0.count }
            .assign(to: &$characterCount)
        
        // Transform count → color
        $characterCount
            .map { count in
                switch count {
                case 0..<200: return .primary
                case 200..<280: return .orange
                case 280...: return .red
                default: return .primary
                }
            }
            .assign(to: &$countColor)
    }
}
```

**Option B (@Observable):**
```swift
@Observable
class ComposeViewModel {
    var postText: String = ""
    
    // Computed properties - no side effects needed!
    var characterCount: Int {
        postText.count
    }
    
    var countColor: Color {
        switch characterCount {
        case 0..<200: return .primary
        case 200..<280: return .orange
        case 280...: return .red
        default: return .primary
        }
    }
}
```

**Winner: Option B** - computed properties are perfect for derived state

---

### Example 6: Advanced Pattern - Retry Logic

**Scenario:** Fetch timeline, retry 3 times with exponential backoff on failure.

**Option C (Combine):**
```swift
class TimelineViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchTimeline() {
        isLoading = true
        
        apiClient.fetchTimeline()
            .retry(3)  // Built-in retry!
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] posts in
                    self?.posts = posts
                }
            )
            .store(in: &cancellables)
    }
}
```

**Option B (@Observable):**
```swift
@Observable
class TimelineViewModel {
    var posts: [Post] = []
    var isLoading: Bool = false
    var error: Error?
    
    func fetchTimeline() async {
        isLoading = true
        
        // Manual retry logic
        for attempt in 1...3 {
            do {
                posts = try await apiClient.fetchTimeline()
                error = nil
                break  // Success!
            } catch {
                if attempt == 3 {
                    self.error = error  // Final attempt failed
                } else {
                    try? await Task.sleep(for: .seconds(Double(attempt)))
                }
            }
        }
        
        isLoading = false
    }
}
```

**Winner: Option C** - `.retry()` operator is more elegant

---

## When Each Approach Excels

### **Option C (Combine) is better for:**

1. **Debouncing/Throttling** user input
2. **Complex operator chains** (map, filter, combineLatest, merge)
3. **Retry logic** and error recovery
4. **Multiple simultaneous streams** that need coordination
5. **Time-based operations** (delays, timeouts, intervals)
6. **Backpressure** handling in data streams

### **Option B (@Observable) is better for:**

1. **Computed properties** (derived state)
2. **Simple async/await** workflows
3. **Minimal side effects**
4. **Clear, imperative** logic
5. **Performance-critical** scenarios
6. **Testing simplicity**

---

## Real-World Example: Your Bluesky App

Looking at your AppState code (lines 104-120), you're using Combine's strengths:

```swift
private func observeChanges() {
    // ✅ This is EXACTLY what Combine is good at
    $bookmarkedPosts
        .debounce(for: 0.5, scheduler: RunLoop.main)
        .sink { [weak self] bookmarks in
            self?.persistenceManager.saveBookmarks(bookmarks)
        }
        .store(in: &cancellables)
    
    $currentUser
        .sink { [weak self] user in
            if let did = user?.did {
                self?.persistenceManager.setLastActiveAccount(did)
            }
        }
        .store(in: &cancellables)
}
```

**If you switched to @Observable**, you'd need to rewrite this as:

```swift
var bookmarkedPosts: Set<String> = [] {
    didSet { 
        debounceSaveBookmarks() 
    }
}

var currentUser: Author? {
    didSet {
        if let did = currentUser?.did {
            Task {
                await persistenceManager.setLastActiveAccount(did)
            }
        }
    }
}

private var bookmarkSaveTask: Task<Void, Never>?

private func debounceSaveBookmarks() {
    bookmarkSaveTask?.cancel()
    bookmarkSaveTask = Task { [weak self] in
        try? await Task.sleep(for: .seconds(0.5))
        guard let self = self, !Task.isCancelled else { return }
        await self.persistenceManager.saveBookmarks(self.bookmarkedPosts)
    }
}
```

**More code, more manual management.** For your use case with reactive persistence patterns, **Option C (Combine) is likely the better choice**.