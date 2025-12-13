# Sentinel Journal

## 2024-05-23 - Insecure File Overwrite in Storage
**Vulnerability:** The `uploadFile` method used raw user-provided filenames directly in the storage path `task_documents/$fileName`. This allowed any user to overwrite any other user's file by uploading a file with the same name (e.g., "report.pdf"), causing data loss and potential integrity issues.
**Learning:** Cloud storage buckets (like Firebase Storage) often have a flat namespace per folder. Without unique identifiers, collisions are inevitable and dangerous.
**Prevention:** Always scope user uploads with a unique identifier (UUID) and/or timestamp. Additionally, sanitize the original filename to prevent directory traversal or weird character issues.
