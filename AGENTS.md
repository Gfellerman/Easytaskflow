# Jules Context & Instructions

## 1. Project Overview
* **App Name:** EasyTaskFlow
* **Goal:** A collaborative project management mobile app (Android/iOS). It allows users (solo or teams) to create projects, assign tasks, set deadlines, and chat via real-time messaging.
* **Current Status:** ~70% complete but **CURRENTLY BROKEN**. The app does not compile.

## 2. User Context (CRITICAL)
* **Role:** The Product Owner is **NOT a coder**.
* **Communication:** Explain issues in plain English. Do not ask the user to manually edit code unless 100% necessary.
* **Workflow:**
    1.  Analyze the error.
    2.  Fix the code yourself.
    3.  **Verify** the fix by running `flutter analyze`.
    4.  **COMMIT** the changes to the repository immediately so the user can sync.

## 3. Tech Stack
* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Auth, Firestore, Storage)
* **State Management:** Mixed (Riverpod + setState) - *Be careful here, this is a known source of bugs.*
* **Key Dependencies:**
    * `firebase_core`, `cloud_firestore`
    * `google_mobile_ads` (AdMob)
    * `googleapis` (Calendar sync)

## 4. Immediate Priority: FIX THE BUILD
**Do not add features.** The only goal right now is to make `flutter build apk` succeed.

**Known Compilation Errors:**
1.  **Naming Mismatch:** The code calls `addUserToProject` but the definition in `database_service.dart` is likely named `addMemberToProject`. **Action:** Rename the call to match the definition.
2.  **Android Config:** `android/app/build.gradle.kts` is missing the `applicationId`. **Action:** Set it to `com.easytaskflow.app` (or similar).
3.  **Pubspec:** Ensure `pubspec.yaml` uses a stable SDK version (`>=3.0.0 <4.0.0`) and does not use deprecated packages like dynamic links if possible.

## 5. Coding Standards
* **Structure:** The project is in the ROOT directory.
* **Imports:** Always check that imports point to valid files.
* **Safety:** Do not delete existing business logic. If a library is missing, install it (`flutter pub add`).