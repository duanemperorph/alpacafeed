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