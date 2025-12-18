# Handover Report

**Status:** Phase 1 Complete (Visual Foundation & Auth) / Phase 2 (AI) Infrastructure Ready

## Architecture Overview

The application is built using **Flutter** for cross-platform support (Android, iOS, Web).

*   **State Management:** **Riverpod** is now established as the standard for new features (Dashboard, Navigation, My Tasks), coexisting with legacy `setState` in older screens.
*   **Backend & Database:** **Firebase** is the core infrastructure.
    *   **Auth:** Firebase Auth (Email/Password & Google Sign-In).
    *   **Database:** Cloud Firestore for storing Users, Projects, Tasks, and Messages.
    *   **Storage:** Firebase Storage for file attachments (Internal).
*   **Cloud Integrations:** Abstracted `CloudStorageService` supporting **Google Drive** and Internal storage, with infrastructure for OneDrive/Dropbox.
*   **External Integrations:**
    *   **Google APIs:** Google Drive (Files), Google Calendar (Sync).
    *   **Dynamic Links:** Firebase Dynamic Links for project invitations.
    *   **Monetization:** Google Mobile Ads (AdMob).

## Feature Status

### Fully Implemented
*   **Authentication:** Sign up, Login (Email & Google), and Logout.
*   **Dashboard:** Real-time aggregated metrics (Tasks Due, Projects), "Upcoming Deadlines" (including subtasks), and "Recent Activity".
*   **Task Management:**
    *   Create/Edit/Delete tasks.
    *   **3-State Status:** Todo / In Progress / Done (cycling UI) for Tasks and Subtasks.
    *   **My Tasks:** Dedicated screen for tasks assigned to the current user.
*   **File Management:**
    *   Upload local files (Web compatible).
    *   Attach files from **Google Drive**.
    *   Delete files.
*   **Settings:**
    *   Notification Preferences (toggle).
    *   **AI Configuration:** Bring Your Own Key (BYOK) for Gemini API.
    *   **Integrations:** Manage cloud provider connections.
*   **Navigation:** Responsive layout (Sidebar/BottomBar) with cross-screen redirection.

### Partially Implemented / WIP
*   **AI Features:** Natural Language Entry is stubbed/ready for Gemini integration using the stored API key.
*   **Custom Cloud Providers:** Infrastructure exists, but generic "Custom Cloud" UI is not yet built.

## Gap Analysis

1.  **AI Feature Activation:**
    *   **Status:** Infrastructure ready (Key storage).
    *   **Action:** Connect `AiService` to "Smart Subtask Generator" and "Natural Language Entry" UI flows.

2.  **Extended Cloud Support:**
    *   **Status:** Google Drive implemented. OneDrive/Dropbox placeholders exist.
    *   **Action:** Implement `OneDriveService` and `DropboxService` or a generic "Custom Cloud" connector.

3.  **Test Coverage:**
    *   **Status:** Unit tests needed for new Providers and Services.
    *   **Action:** Add tests for `DashboardProvider` and `GoogleDriveService`.

## Inferred Goal

The app is evolving into a professional-grade, AI-enhanced project management tool with strong integration capabilities, aiming to support both free users (local/basic cloud) and power users (AI features, advanced integrations).
