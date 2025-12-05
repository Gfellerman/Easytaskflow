# AI Strategy: Free & Paid Tiers

This document outlines a strategy for integrating AI features into EasyTaskFlow, starting with low-cost/free implementations and evolving into premium features.

## 1. Smart Subtask Generator
**Goal:** Help users break down complex tasks into manageable steps.
**Implementation:**
*   **Trigger:** When a user creates a task (e.g., "Organize Conference"), a "Generate Subtasks" button appears.
*   **Tech (Free Tier):** Use **Google Gemini Flash** (via Firebase Extensions or direct API). It has a generous free tier suitable for startup volumes.
*   **Prompt:** "Break down the task '$taskName' into 3-5 concise subtasks for a project management app. Return only a JSON list."

## 2. Natural Language Task Entry
**Goal:** Speed up task creation by parsing user intent.
**Implementation:**
*   **User Action:** User types "Submit report next Friday at 2pm" into a quick-add box.
*   **Tech (Free):** Use a local RegEx/NLP library (like `chrono` in JS, or Dart equivalents like `api_nlp` or custom logic) to extract Date/Time.
*   **Tech (Enhanced):** Use Gemini to parse complex requests: "Schedule a meeting with Bob every Tuesday."
*   **Result:** Auto-fills the Task Form (Name: Submit report, Due: Next Friday 14:00).

## 3. Tone & Politeness Checker (Messaging)
**Goal:** Improve team collaboration in the Messages tab.
**Implementation:**
*   **Trigger:** As the user types a message in the project chat.
*   **Tech (Free):** On-device TensorFlow Lite model for sentiment analysis (totally free, offline).
*   **Feedback:** If sentiment is negative/aggressive, show a subtle "Review tone?" tooltip.

## 4. Smart Scheduling (Premium Feature Idea)
**Goal:** Find the best time to do a task based on Google Calendar.
**Implementation:**
*   **Tech:** Requires reading the user's Google Calendar busy/free slots.
*   **Logic:** "Find a 1-hour slot for 'Focus Work' this week."
*   **Monetization:** This saves significant time and is a high-value "Pro" feature.

## Technical Roadmap
1.  **Phase 1 (Now):** Implement Natural Language Entry using local logic (Zero cost).
2.  **Phase 2 (Next):** Integrate Gemini API for Subtask Generation (Low cost/Free tier).
3.  **Phase 3 (Future):** Train a custom model for project risk assessment (Paid tier).
