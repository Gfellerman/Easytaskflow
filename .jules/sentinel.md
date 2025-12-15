## 2025-12-15 - Insecure File Upload Implementation
**Vulnerability:** The `uploadFile` method in `DatabaseService` directly used the user-provided filename for the storage path (`task_documents/$fileName`).
**Learning:** Trusting user input for file paths in storage buckets creates two risks:
1.  **Overwrite Risk:** A user uploading a file with the same name as an existing file (e.g., "document.pdf") would overwrite the previous file, causing data loss.
2.  **Path Traversal Risk:** Although less likely with modern SDKs, malicious filenames (e.g., "../../etc/passwd") could theoretically attempt to write outside the intended directory structure.
**Prevention:** Always generate a unique, random filename (e.g., UUID) on the server/client side for storage, regardless of the original filename. Store the original filename in metadata or a database record if needed for display.
