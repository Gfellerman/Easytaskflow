# Bolt's Journal

Use this file to record critical performance learnings and architectural insights.

## 2024-05-22 - Flutter StreamBuilder Optimization
**Learning:** Creating Streams inside `build()` method causes unnecessary re-subscriptions on every widget rebuild, wasting resources and causing potential UI flickers.
**Action:** Always initialize Streams in `initState()` and store them in a state variable.

## 2024-05-22 - Navigation Safety
**Learning:** Double `Navigator.pop(context)` calls can accidentally close the parent screen if the context is still mounted.
**Action:** Verify navigation logic carefully and ensure `pop` is called only once per intended action (e.g., closing a dialog).
