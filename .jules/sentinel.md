## 2024-05-23 - File Upload Insecurity Discovered
**Vulnerability:** `DatabaseService.uploadFile` used raw user-provided filenames for storage paths.
**Learning:** Documentation/Memory claimed UUIDs were used, but code did not match. Always verify security claims in code.
**Prevention:** Implemented UUID-based filename generation in `uploadFile` to enforce uniqueness and prevent path traversal.
