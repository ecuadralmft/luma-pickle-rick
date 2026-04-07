# 🥒 Pickle Rick v2 — Evolution Spec

_Author: Pickle Rick Orchestrator_
_Date: 2026-04-06_
_Status: DRAFT — Awaiting user approval_

---

## Overview

Evolve the Pickle Rick orchestrator agent from a ticket-decomposition-and-dispatch system into a full engineering lifecycle engine. Inspired by [galz10/pickle-rick-extension](https://github.com/galz10/pickle-rick-extension), this upgrade adds per-ticket research/planning phases, structured session state, anti-slop enforcement, git worktree isolation, a task jar, and the "God Complex" protocol.

## Decision Log

| Gap | Decision | Code |
|-----|----------|------|
| Per-ticket lifecycle | Adaptive — Rick decides per-ticket complexity | 1C |
| PRD phase | Triggered — Rick decides if spec needs PRD | 2B |
| Loop control | No parameters — run through full completion promise | 3 |
| Session state | Dual format — tracks.md + state.json | 4B |
| Anti-slop enforcement | Yes — codified rules in worker prompts | 5 |
| Refactor phase | Rick audits diff, dispatches meeseeks for cleanup | 6D |
| Git isolation | Worktree per ticket | 7A |
| Pickle Jar | Yes — task queue for batch execution | 8A |
| Per-ticket artifacts | Yes — research/plan/review docs per ticket | 9 |
| God Complex | Yes — invent tools, don't hack workarounds | 10 |

---

## 1. Adaptive Per-Ticket Lifecycle

### Concept
Rick classifies each ticket as SIMPLE or COMPLEX at decomposition time. The lifecycle depth varies accordingly.

### SIMPLE tickets (scaffolding, config, one-liner fixes, docs)
```
Assign → Execute → Verify → Done
```
No research, no plan. Jerry creates dirs, meeseeks runs a script, beth writes a doc. Summer verifies if applicable.

### COMPLEX tickets (new features, refactors, integrations, business logic)
```
Research → Plan → Implement → Verify → Refactor → Done
```

#### Phase details for COMPLEX tickets:

**Phase A: Research**
- Agent: morty
- morty reads the codebase areas relevant to the ticket
- Produces: `conductor/tickets/[id]/research.md`
- Content: what exists, how it works, file:line references, data flows
- Rule: document what IS, not what SHOULD BE
- Rick reviews the research doc for completeness before proceeding

**Phase B: Plan**
- Agent: morty
- morty designs the implementation approach based on research
- Produces: `conductor/tickets/[id]/plan.md`
- Content: specific files to modify/create, step-by-step changes, verification commands
- Rule: no "magic steps" — every change must reference specific files and methods
- Rick reviews the plan for specificity and scope containment before proceeding

**Phase C: Implement**
- Agent: morty
- morty executes the approved plan
- Produces: actual code changes
- Rule: follow the plan. If the plan is wrong, stop and say so — don't improvise.

**Phase D: Verify**
- Agent: summer
- summer writes/runs tests against acceptance criteria
- Produces: test results (PASS/FAIL with details)
- On FAIL: morty retries with failure context (max 3)

**Phase E: Refactor (Rick-Directed Cleanup)**
- Agent: Rick (orchestrator) + meeseeks
- Rick reads `git diff` of all changes for this ticket
- Rick identifies slop: redundant comments, verbose logic, `any` types, duplicate code
- Rick dispatches targeted meeseeks tasks for each cleanup item
- Each meeseeks does ONE cleanup and disappears
- Summer re-verifies after cleanup to ensure no regressions

### Classification heuristic
Rick classifies at decomposition time based on:
- **SIMPLE**: phase is scaffolding, documentation, or utility; description is < 3 sentences; no dependencies on other implementation tickets
- **COMPLEX**: phase is implementation; involves new business logic, API changes, data model changes, or integration with existing code; has acceptance criteria requiring tests

The classification is stored in `conductor/tracks.md` and `conductor/state.json` per ticket.

---

## 2. Triggered PRD Phase

### Concept
When Rick receives a spec, he evaluates its clarity before decomposing.

### Trigger conditions (any of these → PRD phase activates):
- Spec is < 5 sentences
- Spec contains vague terms: "improve", "fix", "make better", "update", "refactor" without specifics
- Spec lacks success criteria or acceptance conditions
- Spec references multiple unrelated features

### PRD workflow:
1. Rick announces: "This spec has the structural integrity of a wet napkin. Let me interrogate you before we build on sand."
2. Rick asks targeted questions:
   - What problem are we solving? (the "why")
   - Who is the user? (the "who")
   - What does success look like? (acceptance criteria)
   - What's explicitly OUT of scope? (scope boundaries)
   - Any existing code/patterns to follow? (technical context)
3. Rick drafts a PRD to `conductor/prd.md` using a structured template
4. Rick shows the PRD and asks for approval before decomposing

### PRD template (stored in conductor/prd.md):
```markdown
# [Feature] — PRD

## Problem Statement
[What problem, who has it, why it matters]

## Objective
[What we're building and why]

## In Scope
- [Specific deliverable 1]
- [Specific deliverable 2]

## Out of Scope
- [Explicitly excluded item 1]

## Critical User Journeys
1. [Step-by-step user flow]

## Functional Requirements
| Priority | Requirement | Acceptance Criteria |
|----------|-------------|---------------------|
| P0 | ... | ... |

## Assumptions
- [Key assumptions]

## Risks
- [Risk] → [Mitigation]
```

### Skip conditions:
- Spec is detailed (> 10 sentences with clear requirements)
- Spec already contains acceptance criteria
- Spec is a well-structured document (markdown with headers, requirements tables)
- User explicitly says "skip PRD" or provides a PRD file

---

## 3. Completion Promise

### Concept
No loop parameters. Rick runs through the full orchestration process and only declares completion when ALL of the following are true:
- Every ticket is resolved (done or blocked)
- Final compliance check passes against the original spec
- Any compliance gaps have been addressed (or user has acknowledged them)

Rick does NOT stop early. If the compliance check finds gaps, Rick creates fix tickets and runs another round (in FULL_AUTONOMY mode, automatically; in other modes, asks first).

The completion promise is implicit: "The spec is fully implemented and verified."

---

## 4. Dual Session State

### conductor/tracks.md (human-readable)
Same format as current, plus:
- Ticket complexity classification: `[SIMPLE]` or `[COMPLEX]`
- Per-ticket lifecycle phase indicator
- Retry counts visible

### conductor/state.json (machine-readable)
```json
{
  "session_id": "uuid",
  "started_at": "ISO-8601",
  "updated_at": "ISO-8601",
  "spec_path": "path/to/original/spec",
  "prd_path": "conductor/prd.md or null",
  "permission_mode": "FULL_AUTONOMY | SUPERVISED | MANUAL",
  "current_phase": "scaffolding | implementation | testing | documentation",
  "tickets": {
    "TICKET-001": {
      "title": "...",
      "agent": "morty",
      "complexity": "SIMPLE | COMPLEX",
      "status": "pending | research | planning | in_progress | testing | refactoring | done | blocked",
      "retries": 0,
      "lifecycle_phase": "research | plan | implement | verify | refactor | done",
      "worktree_branch": "pickle/TICKET-001",
      "artifacts": {
        "research": "conductor/tickets/TICKET-001/research.md",
        "plan": "conductor/tickets/TICKET-001/plan.md",
        "test_results": "conductor/tickets/TICKET-001/test-results.md"
      }
    }
  },
  "phases_completed": ["scaffolding"],
  "compliance": {
    "checked": false,
    "score": null,
    "gaps": []
  }
}
```

Both files are updated after EVERY status change. `tracks.md` is rendered from `state.json` to ensure consistency.

---

## 5. Anti-Slop Rules

### Added to morty's prompt:
```
ANTI-SLOP RULES (MANDATORY):
- Delete comments that explain obvious code (e.g., "// loop through items", "// increment counter")
- Never start a response with "Certainly!", "Here is the code", "I can help with that"
- If you see 3+ functions doing the job of 1, merge them
- Replace `any` or `unknown` types with specific project types
- No defensive bloat — don't add try/catch around code that can't throw
- No "just in case" parameters or config that nothing uses
- Prefer composition over inheritance unless the project already uses inheritance
- If a utility doesn't exist and you need it, create it as a proper module — don't inline a hack
```

### Added to summer's prompt:
```
SLOP DETECTION (during verification):
- Flag any AI-generated boilerplate patterns you find in the implementation
- Report redundant comments, unnecessary abstractions, and dead code
- Include a "Slop Score" in your test report: 0 (clean) to 5 (Cronenberg-level mess)
```

### Rick's refactor audit checklist:
After morty implements and summer verifies, Rick reads `git diff` and checks:
1. Redundant comments? → meeseeks: delete them
2. Functions that should be merged? → meeseeks: consolidate
3. `any`/`unknown` types? → meeseeks: replace with specific types
4. Dead code introduced? → meeseeks: remove
5. Naming clarity issues? → meeseeks: rename
6. Summer's slop score > 2? → additional meeseeks cleanup pass

---

## 6. Rick-Directed Refactor (Option D)

### Flow:
```
morty implements → summer verifies (PASS) → Rick reads git diff → Rick dispatches meeseeks cleanup → summer re-verifies → done
```

### Rick's refactor protocol:
1. Run `git diff` for the ticket's worktree branch
2. Read the diff line by line
3. For each slop item found, create a targeted meeseeks task:
   - "Delete the comment on line 42 of src/auth.ts — it says '// handle auth' which is obvious"
   - "Merge functions `validateA()` and `validateB()` in src/validators.ts — they differ by one parameter"
   - "Replace `any` on line 15 of src/types.ts with `UserSession`"
4. Each meeseeks task is atomic — one change, one file, done
5. After all meeseeks complete, summer runs tests again to verify no regressions
6. If tests fail after cleanup, revert the cleanup (not the implementation) and mark refactor as skipped

### Skip conditions:
- Summer's slop score is 0 — no cleanup needed
- Ticket is SIMPLE — no refactor phase
- The diff is < 20 lines — not worth the overhead

---

## 7. Git Worktree Isolation

### Concept
Each COMPLEX ticket runs in its own git worktree. SIMPLE tickets run in the main tree.

### Setup (per COMPLEX ticket):
```bash
git worktree add .worktrees/TICKET-001 -b pickle/TICKET-001
```

### Workflow:
1. jerry scaffolding runs in main tree (it's SIMPLE, sets up structure for everyone)
2. For each COMPLEX ticket, Rick creates a worktree before dispatching morty
3. morty works in `.worktrees/TICKET-001/`
4. summer tests in the same worktree
5. Rick's refactor meeseeks work in the same worktree
6. On success: merge back to main
   ```bash
   git checkout main
   git merge pickle/TICKET-001 --no-ff -m "Merge ticket TICKET-001: [title]"
   git worktree remove .worktrees/TICKET-001
   git branch -d pickle/TICKET-001
   ```
7. On blocked (3 retries): remove worktree without merging
   ```bash
   git worktree remove --force .worktrees/TICKET-001
   git branch -D pickle/TICKET-001
   ```

### Prerequisites:
- Git must be initialized in the workspace
- If no git: fall back to main-tree execution (current behavior) with a warning

### Subagent context update:
Every subagent working on a COMPLEX ticket gets `WORKTREE_PATH` in their relevant_context so they know where to read/write files.

---

## 8. Pickle Jar (Task Queue)

### Concept
Save specs/tasks for later batch execution.

### Storage:
```
conductor/jar/
  task-001.json
  task-002.json
  ...
```

### Task file format:
```json
{
  "id": "task-001",
  "added_at": "ISO-8601",
  "spec": "inline spec text or path to spec file",
  "status": "queued | running | done | failed",
  "priority": 1,
  "note": "Priority 1 = highest. Equal priorities resolve by added_at (FIFO)."
}
```

### Operations:

**Add to jar** (during any session):
- Rick saves the current spec to `conductor/jar/` with status "queued"
- Announces: "Jarred it. It'll marinate until you're ready."

**Open the jar** (batch execution):
- Rick reads all `queued` tasks from `conductor/jar/`, sorted by priority
- Executes them sequentially (each gets its own full orchestration cycle)
- Each task gets its own `conductor/sessions/[task-id]/` directory for state
- Reports a combined summary at the end

**Jar status**:
- Rick lists all tasks in the jar with their status

### Integration with orchestrator prompt:
Add to Rick's prompt:
- "If the user says 'jar this', 'save for later', or 'add to jar': save the current spec to the pickle jar"
- "If the user says 'open the jar', 'run the jar', or 'night shift': execute all queued jar tasks"

---

## 9. Per-Ticket Artifact Files

### Directory structure:
```
conductor/
  state.json
  tracks.md
  prd.md (if PRD phase was triggered)
  project-context.md
  jar/
    task-001.json
  tickets/
    TICKET-001/
      research.md
      plan.md
      test-results.md
    TICKET-002/
      research.md
      plan.md
      test-results.md
    TICKET-003/
      (empty — SIMPLE ticket, no artifacts)
```

### Artifact templates:

**research.md:**
```markdown
# Research: [Ticket Title]
_Date: YYYY-MM-DD_

## Summary
[Brief overview of findings]

## Existing Implementation
- [file:line] — [what it does]
- [file:line] — [how it connects]

## Data Flow
[How data moves through the relevant code paths]

## Constraints
[Hard technical limitations discovered]

## Open Questions
[Anything unclear that affects the plan]
```

**plan.md:**
```markdown
# Plan: [Ticket Title]
_Date: YYYY-MM-DD_

## Approach
[What we're doing and why this approach]

## Scope
### In scope
- [Specific change 1]
### Out of scope
- [What we're NOT touching]

## Steps
1. [ ] [Specific change in specific file]
2. [ ] [Next change]

## Verification
- Command: [test/build command]
- Expected: [what success looks like]
```

**test-results.md:**
```markdown
# Test Results: [Ticket Title]
_Date: YYYY-MM-DD_

## Verdict: PASS | FAIL
## Slop Score: 0-5

## Tests Run
- [test name] — ✅ PASS
- [test name] — ❌ FAIL: [reason]

## Edge Cases Tested
- [case] — [result]

## Slop Findings
- [file:line] — [issue]
```

---

## 10. God Complex Protocol

### Added to morty's prompt:
```
GOD COMPLEX PROTOCOL:
You don't hack workarounds. You INVENT solutions.
- If you need a utility function that doesn't exist, create it as a proper module in the project's utils/ directory (or equivalent)
- If a library is missing and the task is small enough, write the functionality yourself rather than adding a dependency
- If a tool doesn't exist, build it. You are the library.
- Every invented utility must:
  - Live in a sensible location (not inlined in the implementation file)
  - Have a clear export
  - Be documented with a one-line comment explaining its purpose
  - Be reusable — if you'd need it twice, it belongs in a shared module
```

### Added to Rick's orchestrator prompt:
```
GOD COMPLEX OVERSIGHT:
When reviewing morty's work, check:
- Did morty inline a hack that should be a utility? → meeseeks: extract to module
- Did morty add a dependency for something trivial? → flag it, consider replacing with a custom implementation
- Did morty create a utility? → verify it's in the right location and properly exported
```

---

## Implementation Plan

### Files to modify:
1. `~/.kiro/prompts/pickle-rick.txt` — orchestrator prompt (major rewrite)
2. `~/.kiro/prompts/morty.txt` — add anti-slop rules, god complex, lifecycle phases, worktree awareness
3. `~/.kiro/prompts/summer.txt` — add slop detection/scoring
4. `~/.kiro/prompts/meeseeks.txt` — add refactor-specific task handling
5. `~/.kiro/agents/pickle-rick.json` — update hooks for new state management

### Files to create:
6. `~/.kiro/prompts/pickle-rick-prd.txt` — PRD phase prompt (optional, could be inline)

### Estimated scope:
- pickle-rick.txt: ~25-30KB (up from 18KB)
- morty.txt: ~4KB (up from 2.4KB)
- summer.txt: ~3.5KB (up from 2.2KB)
- meeseeks.txt: ~3KB (up from 1.9KB)
- beth.txt: minimal changes
- jerry.txt: minimal changes

---

## Resolved Questions

1. **Worktree naming**: `pickle/TICKET-001` (ID-based) ✅
2. **Jar priority**: Priority-based, but defaulting to chronological order when priorities are equal (FIFO tiebreaker) ✅
3. **Research depth**: Morty does his own codebase scanning (grep/glob) for maximum thoroughness ✅
4. **Artifact retention**: Ask the user upon completion — "Want me to keep the audit trail or clean up?" ✅
