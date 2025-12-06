# Jules Context & Instructions

## Project Goal
**EasyTaskFlow** is a collaborative project management app (mobile).
It allows users (solo or groups) to create projects, assign tasks, set deadlines (synced to Google Calendar), and chat via real-time messaging.
**Target Audience:** Private or professional users needing simple project oversight.

## Current State & Critical Context
* **Completion:** ~70% theoretically, but currently **BROKEN**.
* **Blocker:** The app does not compile/build. We cannot generate an APK.
* **User Context:** The Product Owner is **NOT a coder**.
    * Explain issues in plain English.
    * Do not ask the user to manually edit code unless 100% necessary.
    * **CRITICAL:** When you fix code, you must `git commit` and `git push` your changes so the user can see them.

## Tech Stack
* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Auth, Firestore, Storage)
* **Key Integrations:** Google Calendar API, AdMob, Firebase Dynamic Links.
* **State Management:** Mixed (Riverpod + setState) -> *Source of instability.*

## Known Bugs (Fix These First)
Based on a recent audit, these are the blockers preventing the build:
1.  **Naming Mismatch:** `_databaseService.addUserToProject` is called but the definition is `addMemberToProject`.
2.  **Android Config:** `android/app/build.gradle.kts` has missing App IDs/Signatures (TODOs).
3.  **State Management:** Inconsistent use of Riverpod causing provider scope errors.

## Workflow Rules for Jules
1.  **Fix the Build First:** Do not optimize UI or Logic until `flutter build apk` succeeds.
2.  **Verify Imports:** Ensure all imports in Dart files actually exist.
3.  **Dependency Check:** Always run `flutter pub get` after modifying `pubspec.yaml`.