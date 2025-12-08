# Jules Context & Instructions

## 1. Project Overview
- **App Name:** EasyTaskFlow
- **Goal:** A collaborative project management app for Android, iOS, and Web. Users can create projects, assign tasks, set deadlines, and chat in real time.
- **Current Status:** ~70% complete but **CURRENTLY BROKEN**. The app does not compile and the build is failing.

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
- **State Management:** Mixed (Riverpod + `setState`) — **be careful**, this is a known source of bugs.
- **Key Dependencies:**
  - `firebase_core`, `cloud_firestore`
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

## 5. Immediate Priority: FIX THE BUILD
- **Do not add new features.**
- **Primary goal:** Make `flutter build apk` succeed without errors or analyzer warnings.
- **Known issues to address first:**
  1. **Naming mismatch:** Some code calls `addUserToProject` but `database_service.dart` defines `addMemberToProject` (or similar). Align the call and definition so they use a single, consistent name.
  2. **Android config:** `android/app/build.gradle.kts` is missing the `applicationId`. Set it to `com.easytaskflow.app` (or the correct ID if specified elsewhere).
  3. **Pubspec:** Ensure `pubspec.yaml`:
     - Uses `sdk: ">=3.0.0 <4.0.0"` (or another stable range).
     - Uses up‑to‑date, non‑deprecated Firebase and Google packages when possible.

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
