## 2024-05-24 - Secure File Uploads
**Vulnerability:** The `uploadFile` method used user-provided filenames directly in storage paths (`task_documents/$fileName`), allowing file overwrites and potential path traversal.
**Learning:** Documentation/Memory claimed security existed ("enforces unique filenames") but code proved otherwise. Always verify security claims against actual implementation.
**Prevention:** Enforce server-side or service-level filename generation using UUIDs and strict sanitization (allowlist characters) to ensure uniqueness and safety.
