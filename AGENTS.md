# Jules Context & Instructions

## 1. Project Overview
- **App Name:** EasyTaskFlow
- **Goal:** A collaborative project management app for Android, iOS, and Web. Users can create projects, assign tasks, set deadlines, and chat in real time.
- **Current Status:** Phase 1 Complete (Visuals, Auth, Integrations). Phase 2 (AI) Infrastructure Ready.

## 2. User Context (CRITICAL)
- **Role:** The Product Owner is **NOT a coder**.
- **Communication:** Explain issues in plain English. Do **not** ask the user to manually edit code unless absolutely necessary.
- **Workflow you MUST follow:**
  1. Analyze the errors.
  2. Fix the code yourself.
  3. **Verify** by running:
     - `flutter pub get`
     - `flutter analyze`
     - `flutter test` (if tests exist)
     - `flutter build apk`
  4. If commands fail, fix the problems and re-run them until they pass.
  5. **COMMIT** the changes and push a branch / open a PR so the user can sync.

## 3. Tech Stack
- **Frontend:** Flutter (Dart)
- **Platforms:** Android, iOS, Web.
- **Backend:** Firebase (Auth, Firestore, Storage).
- **State Management:** Mixed (Riverpod + `setState`). **Riverpod** is the standard for new features.
- **Key Dependencies:**
  - `firebase_core`, `cloud_firestore`
  - `flutter_riverpod`
  - `google_mobile_ads` (AdMob)
  - `googleapis` (Calendar sync)

## 4. Build & Tooling
- **SDK & Tooling:**
  - Use a stable Flutter SDK compatible with `sdk: ">=3.0.0 <4.0.0"` in `pubspec.yaml`.
  - Avoid deprecated Firebase packages (for example, older dynamic links packages) unless required.
- **Required build commands (run in project root):**
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test` (if tests exist)
  - `flutter build apk`
- If Flutter is not installed in the environment, install it or use the environment where these commands already work.

## 5. Immediate Priority: ACTIVATE AI FEATURES
- **Primary goal:** Connect the now-ready AI Infrastructure (BYOK) to the user-facing features (Smart Subtasks, NL Entry).
- **Secondary goal:** Expand Cloud Integrations (Custom Providers).
- **Maintenance:** Ensure `flutter build web` works (resolved file upload issues).

## 6. Coding Standards
- **Project structure:** Flutter project is in the **root** directory.
- **Imports:** Always ensure imports reference real files; remove or fix broken imports.
- **Safety:**
  - Do **not** delete existing business logic unless it is clearly dead code and safe to remove.
  - If a required package is missing, add it with `flutter pub add <package>` and update `pubspec.yaml` accordingly.
- **Testing:**
  - Prefer adding or updating tests rather than commenting them out.
  - If you must temporarily disable a test, leave a clear TODO explaining why.

## 7. When you are unsure
- If a design choice is ambiguous, choose the safest option that:
  - Keeps the current user flows working.
  - Minimizes breaking changes to public APIs and data models.
- Document any significant trade‑offs in code comments and the PR description.
Validation Rules for Jules:
- You CANNOT run `flutter analyze` in your environment. Never claim you ran it.
- Treat my local `flutter analyze` output as the single source of truth.
- After each change, I will paste errors; your job is to fix ONLY those lines/files.
- Do not modify unrelated files or do broad refactors without an explicit request.
