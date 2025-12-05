# AI Strategy: Smart Task Management

## Goal
Enhance the existing "Easy Task Flow" application by injecting AI capabilities to automate task breakdown and simplify entry.

## 1. Natural Language Task Entry (Magic Input)
**Concept:** Instead of manually filling out "Title", "Date", "Description", "Assignee", the user types a single sentence.
**Example:** "Remind John to fix the login bug by Friday at 2pm."

**Implementation:**
*   **Input:** A simple text field on the dashboard.
*   **AI Processing (LLM):** Parse the string to extract:
    *   **Title:** "Fix login bug"
    *   **Assignee:** "John" (match against Project Members)
    *   **Due Date:** "Friday at 2pm" (convert to ISO timestamp)
    *   **Project:** Infer project context or ask for clarification.
*   **Output:** Pre-fill the "Create Task" form or auto-create the task.

## 2. Smart Subtask Generator
**Concept:** Users often create broad tasks like "Launch Website". This is too vague. AI can break it down.

**Implementation:**
*   **Trigger:** A "Magic Wand" icon next to any task.
*   **AI Processing:** Analyze the task title ("Launch Website").
*   **Output:** A checklist of subtasks:
    1.  Buy Domain
    2.  Setup Hosting
    3.  Deploy Code
    4.  Configure SSL
*   **User Action:** User can accept, edit, or reject the suggested subtasks.

## 3. Prioritization Assistant
**Concept:** When a user has 50 tasks, they don't know what to do first.
**Implementation:**
*   Analyze tasks based on Due Date + Keywords (e.g., "Critical", "Bug", "Client").
*   Re-order the "My Tasks" view to highlight the most urgent items automatically.

## Integration Plan (MVP)
We will focus on **#2 Smart Subtask Generator** first, as it adds high value with low risk (it's purely additive).

1.  **UI:** Add "Generate Subtasks" button to Task Detail screen.
2.  **Service:** Create `AIService` (mocked for now, or using OpenAI API if key provided).
3.  **Logic:** On button press, call Service -> Parse Response -> Add to Firestore Subtasks collection.
