## 2024-05-24 - StreamBuilder Recreation in ListView
**Learning:** In Flutter, creating a Stream directly inside a `StreamBuilder` that is inside a `ListView.builder` causes the stream to be re-created and re-subscribed on every parent rebuild, leading to performance degradation and unnecessary DB reads (stream churn).
**Action:** Always extract the list item into a `StatefulWidget` and initialize the stream in `initState` to ensure the subscription persists across rebuilds unless arguments change.
