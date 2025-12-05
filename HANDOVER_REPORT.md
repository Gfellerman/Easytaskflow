# Handover Report

## Architecture Overview

The application is built using **Flutter** for cross-platform support (Android, iOS, Web).

*   **State Management:** `flutter_riverpod` is included in dependencies, though `setState` and direct Service instantiation are currently used in many screens (e.g., `HomeScreen`, `ProjectsScreen`). This indicates a transition or a mix of patterns.
*   **Backend & Database:** **Firebase** is the core infrastructure.
    *   **Auth:** Firebase Auth (Email/Password & Google Sign-In).
    *   **Database:** Cloud Firestore for storing Users, Projects, Tasks, and Messages.
    *   **Storage:** Firebase Storage for file attachments.
*   **External Integrations:**
    *   **Google APIs:** Integration with Google Calendar to sync tasks.
    *   **Dynamic Links:** Firebase Dynamic Links for project invitations.
    *   **Monetization:** Google Mobile Ads (AdMob) for banner ads.

### Suitability Analysis
The architecture aligns well with the "financially free" startup goal by leveraging Firebase's free tier. However, as the user base grows, Firestore usage (reads/writes) could exceed free limits. The code is heavily coupled to the Google ecosystem.

## Feature Status

### Fully Implemented
*   **Authentication:** Sign up, Login (Email & Google), and Logout.
*   **Project Management:** Create projects (with a hardcoded 50-project limit) and list user's projects.
*   **Messaging:** Real-time messaging within a project context (Firestore backed).
*   **Navigation:** Bottom navigation bar switching between Projects, Messages, and Settings.
*   **Ad Integration:** Banner ads are placed in `ProjectsScreen` and `ProjectDetailScreen`.

### Partially Implemented / WIP
*   **Task Management:** Task creation exists and attempts to sync with Google Calendar. However, task details and subtasks interfaces are referenced but need verification of full functionality.
*   **Invitations:** Logic to invite users by email exists. If the user isn't found, it falls back to sharing a Dynamic Link.
*   **Settings:** The screen exists but is largely non-functional (contains placeholders).

## Gap Analysis

The following issues were identified during the code scan. They are ordered logically to restore a working baseline before adding new features.

1.  **Critical Bug - Compilation/Runtime Error:**
    *   **Location:** `lib/screens/project_detail_screen.dart`
    *   **Issue:** Calls `_databaseService.addUserToProject(...)`, but the method in `DatabaseService` is named `addMemberToProject`.
    *   **Action:** Rename the method call to match the definition.

2.  **Missing Settings Logic:**
    *   **Location:** `lib/screens/settings_screen.dart`
    *   **Issue:** Explicit `TODO` comments found:
        *   `// TODO: Implement profile management`
        *   `// TODO: Implement notification preferences`
    *   **Action:** Implement these features or hide the UI options until ready.

3.  **Android Configuration:**
    *   **Location:** `android/app/build.gradle.kts`
    *   **Issue:** Default `TODO`s remain for Application ID and Signing Config.
    *   **Action:** These must be configured before a release build can be generated.

4.  **State Management Consistency:**
    *   **Observation:** The app imports `riverpod` but heavily uses `StatefulWidget` and local service instantiation.
    *   **Action:** Decide on a standard pattern (migrate to Riverpod providers) to improve testability and state persistence.

5.  **Data Deletion & Editing:**
    *   **Observation:** There is no obvious UI or logic for *deleting* projects or tasks, or *leaving* a project.
    *   **Action:** Add CRUD (Update/Delete) capabilities for projects and tasks.

## Inferred Goal

Based on the codebase, the app is a **collaborative project management tool** rather than just a simple "Todo list". It allows users to:
1.  Create Projects.
2.  Invite other users to those projects.
3.  Assign tasks with due dates (synced to Google Calendar).
4.  Chat with team members within the project.
5.  Share files (implied by `FileModel` and storage dependencies).

It aims to be a free, ad-supported alternative to tools like Trello or Asana, with a strong focus on Google integration.
