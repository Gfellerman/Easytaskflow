# Bolt's Journal ⚡

## 2024-05-23 - O(N*M) Calendar Event Loading
**Learning:** `TableCalendar`'s `eventLoader` callback is executed for every visible day cell. Filtering the entire list of tasks (O(N)) inside this callback results in O(N*M) complexity, causing frame drops as the task list grows.
**Action:** Always pre-group events into a `Map<DateTime, List<Event>>` (O(N)) outside the calendar build to enable O(1) lookups in `eventLoader`.
