Here's my plan:

### 1. Update FeedType Model (`BlueskyFeedSelector.swift`)

Replace the current enum:
```swift
enum FeedType: String, CaseIterable {
    case following = "Following"
    case discover = "Discover"
    case custom = "Custom"
}
```

With a new model:
```swift
enum FeedType: Hashable {
    case following
    case custom(SavedFeed)
}

struct SavedFeed: Hashable, Identifiable {
    let uri: String
    let name: String
    var id: String { uri }
}
```

### 2. Add API Method (`FeedService.swift`)

Add a method to fetch the user's saved feeds using `app.bsky.actor.getPreferences`. This returns preferences including saved feed URIs. We'd then need to hydrate them with `app.bsky.feed.getFeedGenerators` to get the display names.

### 3. Add State for Available Feeds

Store the list of `SavedFeed` somewhere - likely in `NavigationCoordinator` or `AppState` since it's app-wide.

### 4. Create FeedSelectorSheet View

A new sheet view that shows:
- "Following" as the first/default option
- List of saved feeds fetched from API
- Tapping one dismisses the sheet and switches the feed

### 5. Update TopBar UI (`TopBarExpanded.swift`)

Replace `BlueskyFeedSelector` (the chevron switcher) with a single button showing the current feed name. Tapping opens the sheet.

### 6. Update NavigationCoordinator

- Add `showingFeedSelectorSheet: Bool`
- Add `availableFeeds: [SavedFeed]`
- Add method to fetch feeds on app launch/login

### 7. Update ViewModelFactory Mapping

Update `mapToRepositoryFeedType` to handle the new `FeedType.custom(SavedFeed)` case.

---

Does this plan look right? Any changes before I start implementing?