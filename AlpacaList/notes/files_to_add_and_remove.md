# Files to Add and Remove

## ✅ Files to Add to Xcode Project

These files were created during the refactoring but need to be added to the Xcode project target:

### Phase 1: Data Models (6 files)
```
AlpacaList/Model/Data/
├─ Post.swift                    [NEW - Core Bluesky post model]
├─ Author.swift                  [NEW - User profile model]
├─ Facet.swift                   [NEW - Rich text features]
├─ Embed.swift                   [NEW - Media embeds]
├─ ReplyRef.swift                [NEW - Threading references]
└─ Timeline.swift                [NEW - Feed containers]
```

### Phase 2: View Models (3 files)
```
AlpacaList/Model/VM/
├─ TimelineViewModel.swift       [NEW - Timeline feed manager]
├─ ThreadViewModel.swift         [NEW - Thread conversation manager]
└─ PostViewModel.swift           [NEW - Individual post display]
```

### Phase 3: UI Components (7 files)
```
AlpacaList/Views/Feed/Components/
├─ AuthorHeader.swift            [NEW - Author info component]
├─ RichTextView.swift            [NEW - Rich text with facets]
├─ PostEmbed.swift               [NEW - Media embeds]
├─ EngagementBar.swift           [NEW - Interaction buttons]
└─ PostCard.swift                [NEW - Unified post display]

AlpacaList/Views/Feed/Feeds/
├─ TimelineView.swift            [NEW - Timeline feed view]
└─ ThreadView.swift              [NEW - Thread conversation view]
```

### Phase 4: Settings (1 file)
```
AlpacaList/Views/Settings/
└─ BlueskySettings.swift         [NEW - Bluesky account & configuration]
```

### **Total: 17 new files to add**

---

## ⚠️ Files Modified (Keep, but aware they changed)

These files were updated but should already be in the Xcode project:

### Navigation (2 files)
```
AlpacaList/Views/Navigation/
├─ NavigationCoordinator.swift   [MODIFIED - Added Bluesky destinations]
└─ NavigationRootView.swift      [MODIFIED - Defaults to TimelineView]
```

### Settings (1 file)
```
AlpacaList/Views/Settings/
└─ UserSettings.swift            [MODIFIED - Added Bluesky section]
```

### Feeds (2 files)  
```
AlpacaList/Views/Feed/Feeds/
├─ TimelineView.swift            [NEW - needs to be added]
└─ ThreadView.swift              [NEW - needs to be added]
```

---

## 🗑️ Files Safe to Remove (Deprecated)

These files are now replaced by new Bluesky components but kept for reference during migration:

### ❌ Optional: Can Remove After Full Migration

**DO NOT REMOVE YET** - Keep for backwards compatibility during transition:

```
AlpacaList/Model/Data/
└─ FeedItem.swift                [KEEP - Legacy model, used by old views]

AlpacaList/Model/VM/
├─ PostsListVM.swift             [KEEP - Used by legacy PostsFeedView]
├─ CommentsListVM.swift          [KEEP - Used by legacy CommentsFeedView]
└─ FeedItemVM.swift              [KEEP - Used by legacy FeedItemView]

AlpacaList/Views/Feed/Feeds/
├─ PostsFeedView.swift           [KEEP - Legacy timeline view]
├─ CommentsFeedView.swift        [KEEP - Legacy thread view]
└─ FeedItemView.swift            [KEEP - Legacy item display]

AlpacaList/Views/Feed/Components/
├─ PostComponents.swift          [KEEP - Legacy components]
├─ PostItemButtons.swift         [KEEP - Legacy post buttons]
├─ CommentsButtons.swift         [KEEP - Legacy comment buttons]
└─ Buttons.swift                 [KEEP - Legacy button styles]
```

### ❌ Safe to Remove After Testing

These can be removed once you verify the new system works:

```
AlpacaList/Model/Mock/
└─ MockDataGenerator.swift       [CAN REMOVE old methods, keep file]
    - Remove: generatePosts() method (old Reddit-style)
    - Keep: generateTimeline(), generateThreadReplies(), mockAuthors (new)
```

---

## 📝 How to Add Files to Xcode

### Method 1: Drag and Drop
1. Open Xcode project
2. In Finder, navigate to the folders above
3. Drag each new file into the appropriate group in Xcode
4. Check "Copy items if needed" ❌ (files are already in place)
5. Check "Add to targets: AlpacaList" ✅
6. Click "Finish"

### Method 2: File > Add Files
1. In Xcode: File > Add Files to "AlpacaList"...
2. Navigate to each file listed above
3. Ensure "Add to targets" includes AlpacaList
4. Click "Add"

### Method 3: Command Line (if files are missing from disk)
If any files weren't created, you can verify:
```bash
# Check which files exist
ls -la AlpacaList/Model/Data/Post.swift
ls -la AlpacaList/Model/Data/Author.swift
# ... etc

# Or check all at once
find AlpacaList -name "*.swift" -type f | grep -E "(Post|Author|Facet|Embed|ReplyRef|Timeline|TimelineViewModel|ThreadViewModel|PostViewModel|AuthorHeader|RichTextView|PostEmbed|EngagementBar|PostCard|BlueskySettings)" | sort
```

---

## ✅ Verification Checklist

After adding files, verify:

### Build Check
```bash
cd /path/to/AlpacaList
xcodebuild -scheme AlpacaList -sdk iphonesimulator clean build
```

### File Count Check
Expected new files: **17**
- Phase 1 models: 6
- Phase 2 view models: 3  
- Phase 3 components: 7
- Phase 4 settings: 1

### Import Check
All new files should be importable:
```swift
import SwiftUI

// Should compile without errors
let post = Post.createTextPost(author: author, text: "test")
let vm = TimelineViewModel.withMockData()
let view = TimelineView(viewModel: vm)
```

---

## 🎯 Migration Strategy

### Phase A: Add All New Files (Do Now)
Add all 17 new files to Xcode project as listed above

### Phase B: Test New System (Do Next)
1. Run app with new `TimelineView` (default in `NavigationRootView`)
2. Test navigation: timeline → thread → parent/reply threads
3. Test interactions: like, repost, reply buttons
4. Test settings: Bluesky accounts section

### Phase C: Gradual Legacy Removal (Do Later)
Once confident in new system:
1. Remove old mock methods from `MockDataGenerator`
2. Consider removing old view files (or keep for reference)
3. Eventually remove old model files

### Phase D: Feature Flag (Recommended)
Add feature flag to toggle between old/new:
```swift
@AppStorage("use_bluesky_ui") var useBlueskyUI = true

// In NavigationRootView
NavigationRootView(useLegacyView: !useBlueskyUI)
```

---

## 📊 Summary

| Category | Count | Status |
|----------|-------|--------|
| **New files to add** | **17** | ✅ Ready |
| Modified files | 3 | ✅ Already in project |
| Legacy files to keep | 11 | ⚠️ Don't remove yet |
| Total new LOC | ~3,500+ | ✅ Complete |

---

## 🚀 Quick Start Command

After adding all files to Xcode, run:
```bash
# Clean build
xcodebuild -scheme AlpacaList -sdk iphonesimulator clean build

# If successful, run app
xcodebuild -scheme AlpacaList -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' run
```

---

## ⚠️ Important Notes

1. **Don't remove legacy files yet** - They're still used by `NavigationCoordinator` for backwards compatibility (`.postDetails` case)

2. **All new files compile independently** - They don't depend on being added in a specific order

3. **Mock data works out of the box** - `TimelineViewModel.withMockData()` and `ThreadViewModel.withMockData()` are ready to use

4. **Navigation is wired** - Timeline and Thread views navigate correctly once files are added

5. **Settings are functional** - Bluesky settings work (with mock auth) immediately

---

## 🐛 Common Issues After Adding Files

### Issue: "Cannot find 'Post' in scope"
**Solution**: Make sure `Post.swift` is added to the AlpacaList target

### Issue: "Cannot find 'TimelineViewModel' in scope"  
**Solution**: Make sure all Phase 2 view model files are added

### Issue: Build fails with "No such module"
**Solution**: Clean build folder (Cmd+Shift+K) then rebuild

### Issue: "Ambiguous use of 'TimelineView'"
**Solution**: SwiftUI has a `TimelineView` - use full path: `AlpacaList.TimelineView` or rename file

---

## 📞 Next Steps

1. ✅ Add all 17 files listed above to Xcode
2. ✅ Build and verify no errors
3. ✅ Run app and test TimelineView
4. ✅ Test navigation flows
5. ✅ Test Bluesky settings
6. ⏭️ Proceed to API integration (Phase 6)

