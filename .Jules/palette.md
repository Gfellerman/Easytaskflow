## 2024-05-24 - Icon-only buttons need labels
**Learning:** Icon-only buttons (IconButton, FAB) in Flutter default to having no semantic label unless `tooltip` is provided. This makes them inaccessible to screen readers and harder to understand for mouse users.
**Action:** Always add `tooltip` to `IconButton` and `FloatingActionButton` unless they have a visible label (like `.extended`).
