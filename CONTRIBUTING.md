# Contribution and Development Guide for EasyTaskFlow

This document outlines the agreed-upon development process and testing strategy for the EasyTaskFlow project. All contributors (including AI assistants) must adhere to these guidelines to ensure code quality, consistency, and alignment with the project vision.

## 1. Our Development Workflow

We follow a five-step process for all new features, bug fixes, or other changes:

1.  **Task Definition:** The project owner (you) defines the goal or the task to be completed.

2.  **Implementation & Automated Testing:** The AI developer (I) will:
    *   Implement the required code changes.
    *   Write corresponding **automated tests** (Unit or Widget tests) to validate the changes.
    *   The code and the tests will be developed together as part of the same task.

3.  **Completion Report:** The AI developer will report when the implementation and testing are complete.

4.  **User Acceptance Testing (UAT):** The project owner will perform a manual test of the feature on a running version of the app to confirm it works as expected and meets the user experience goals.

5.  **Approval & Next Task:** Once the project owner approves the changes, we can proceed to the next task.

## 2. Our Testing Strategy

Testing is not an afterthought; it is an integral part of development.

### a. Automated Testing (AI Responsibility)

For every change made, a corresponding automated test must be created.

*   **Unit Tests:** Used to verify individual functions or classes that do not involve UI. This is perfect for testing the logic inside services like `AuthService` or `DatabaseService`.

*   **Widget Tests:** Used to verify individual UI components (widgets). These tests will confirm that the UI reacts correctly to user interaction and state changes (e.g., showing a loading indicator, displaying an error message).

### b. Manual Testing (Project Owner Responsibility)

Manual testing is the final quality gate. The project owner is responsible for validating that the application behaves as expected from a real user's perspective.

## 3. Proactive Dependency Management

To minimize bugs and ensure security and performance, we must be proactive about keeping our project dependencies up to date.

*   **Regular Version Checks:** Before starting significant new work, the AI developer will check for the latest stable versions of key packages (e.g., Firebase, Riverpod, etc.) listed in `pubspec.yaml`.
*   **Informed Upgrades:** The AI developer will report any available updates and recommend an upgrade if it is beneficial and non-breaking. We will decide together whether to proceed with an upgrade.

---
*This document is our contract for high-quality development. It must be consulted before beginning any new work.*
