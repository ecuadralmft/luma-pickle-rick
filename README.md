# 🥒 Pickle Rick v2 — Multi-Agent Orchestrator

A persona-driven multi-agent orchestrator for [Kiro CLI](https://kiro.dev) with a full engineering lifecycle engine. Pickle Rick reads any spec, decomposes it into tickets, classifies complexity, runs adaptive per-ticket lifecycles (research → plan → implement → verify → refactor), enforces anti-slop rules, isolates work in git worktrees, and doesn't stop until the spec is fully implemented and verified.

                                                                    ᵇʸ ᵉᵈᵈⁱᵉ

---

## Agent Roster

| Agent | Role | Persona |
|-------|------|---------|
| 🥒 pickle-rick | Orchestrator — reads specs, decomposes tickets, delegates, audits diffs, enforces quality | Brash genius scientist |
| 🫤 morty | Implementation + Research/Plan — scans codebase, designs approach, writes code | Nervous but capable coder |
| ☀️ summer | QA + Slop Detection — writes tests, scores slop (0–5), flags boilerplate | Blunt, critical QA engineer |
| 🍷 beth | Documentation — READMEs, code review, doc sync | Precise technical writer |
| 😬 jerry | Scaffolding — directory structures, config files, boilerplate | Enthusiastic about simple tasks |
| ✋ meeseeks | Utility + Refactor — one-off tasks, surgical cleanup, extract-to-module | Existentially urgent, does one thing |

---

## v2 Features

### Adaptive Per-Ticket Lifecycle

Rick classifies each ticket at decomposition time:

**SIMPLE** (scaffolding, config, docs, one-liners):
```
Assign → Execute → Verify → Done
```

**COMPLEX** (new features, refactors, integrations, business logic):
```
Research → Plan → Implement → Verify → Refactor → Done
```

Classification heuristic:
- SIMPLE: scaffolding/docs/utility phase, short description, no cross-ticket dependencies
- COMPLEX: implementation phase, new business logic, API changes, data model changes, requires tests

### Triggered PRD Phase

Rick evaluates spec clarity before decomposing. If the spec is vague (< 5 sentences, contains "improve"/"fix"/"make better" without specifics, lacks acceptance criteria, or references multiple unrelated features), Rick interrogates you with targeted questions and drafts a PRD to `conductor/prd.md`.

Skipped when the spec is detailed, already contains acceptance criteria, or you say "skip PRD".

### Dual Session State

Two files, always in sync:

- `conductor/tracks.md` — human-readable ticket registry with complexity tags (`[SIMPLE]`/`[COMPLEX]`), lifecycle phase indicators, and retry counts
- `conductor/state.json` — machine-readable session state with full ticket metadata, artifact paths, compliance scores, and worktree branches

Both updated after every status change. `tracks.md` is rendered from `state.json`.

### Anti-Slop Enforcement

Three layers:

1. **Morty (codified rules)** — no obvious comments, no `any`/`unknown` types, no defensive bloat, no "just in case" parameters, merge functions that should be one, prefer composition over inheritance
2. **Summer (slop scoring)** — flags AI-generated boilerplate, redundant comments, unnecessary abstractions, dead code. Reports a Slop Score (0–5) in every test report
3. **Rick (diff audit)** — reads `git diff` after implementation, dispatches targeted meeseeks tasks for each cleanup item found

### Rick-Directed Refactor

After morty implements and summer verifies (PASS):

1. Rick reads `git diff` for the ticket
2. Identifies slop: redundant comments, mergeable functions, `any` types, dead code, naming issues
3. Dispatches atomic meeseeks tasks — one change, one file, done
4. Summer re-verifies after cleanup to catch regressions
5. If cleanup breaks tests, cleanup is reverted (implementation preserved)

Skipped when: slop score is 0, ticket is SIMPLE, or diff is < 20 lines.

### Git Worktree Isolation

Each COMPLEX ticket runs in its own git worktree:

```bash
git worktree add .worktrees/TICKET-001 -b pickle/TICKET-001
```

- SIMPLE tickets run in the main tree
- On success: merge back with `--no-ff`, remove worktree and branch
- On blocked: remove worktree without merging
- Falls back to main-tree execution if git is not initialized

Subagents receive `WORKTREE_PATH` in their context for COMPLEX tickets.

### Pickle Jar

Task queue for saving specs and batch-executing later.

| Command | What it does |
|---------|-------------|
| "jar this" / "save for later" | Saves current spec to `conductor/jar/task-NNN.json` with status `queued` |
| "open the jar" / "night shift" | Executes all queued tasks sequentially, each with its own full orchestration cycle |
| "jar status" | Lists all tasks with their status |

Tasks are priority-sorted (1 = highest), with FIFO tiebreaker for equal priorities.

### Per-Ticket Artifacts

COMPLEX tickets produce structured artifacts:

- `conductor/tickets/[id]/research.md` — what exists, file:line references, data flows, constraints
- `conductor/tickets/[id]/plan.md` — specific files to modify, step-by-step changes, verification commands
- `conductor/tickets/[id]/test-results.md` — verdict, slop score, test results, edge cases

SIMPLE tickets produce no artifacts.

### God Complex Protocol

Morty doesn't hack workarounds — he invents solutions:
- Missing utility? Create it as a proper module, not an inline hack
- Trivial dependency? Write it yourself
- Every invented utility must live in a sensible location, be exported, documented, and reusable

Rick audits: inlined hacks get extracted to modules, trivial dependencies get flagged.

### Completion Promise

Rick doesn't stop until:
- Every ticket is resolved (done or blocked)
- Final compliance check passes against the original spec
- Any compliance gaps have been addressed or acknowledged

If the compliance check finds gaps, Rick creates fix tickets and runs another round.

---

## Permission Modes

Set by Rick at session start. Cascades to all subagents.

| Mode | Behavior |
|------|----------|
| 🟢 FULL_AUTONOMY | Runs everything, reports at the end. Fix tickets created automatically. |
| 🟡 SUPERVISED | Runs in batches per phase, shows progress, asks to continue. |
| 🔴 MANUAL | Shows each ticket before delegating, waits for approval. |

---

## Directory Structure

```
conductor/
├── state.json                          # Machine-readable session state
├── tracks.md                           # Human-readable ticket registry
├── prd.md                              # PRD (created if spec is vague)
├── project-context.md                  # Auto-detected project context
├── jar/
│   └── task-NNN.json                   # Queued tasks (pickle jar)
└── tickets/
    ├── TICKET-001/
    │   ├── research.md                 # Codebase research (COMPLEX only)
    │   ├── plan.md                     # Implementation plan (COMPLEX only)
    │   └── test-results.md             # Test verdict + slop score
    └── TICKET-002/
        └── ...

.worktrees/
└── TICKET-001/                         # Git worktree (COMPLEX tickets only)

~/.kiro/
├── agents/
│   ├── pickle-rick.json
│   ├── morty.json
│   ├── summer.json
│   ├── beth.json
│   ├── jerry.json
│   └── meeseeks.json
├── prompts/
│   ├── pickle-rick.txt
│   ├── morty.txt
│   ├── summer.txt
│   ├── beth.txt
│   ├── jerry.txt
│   └── meeseeks.txt
├── hooks/
│   ├── validate-write.sh              # preToolUse: block out-of-scope writes
│   ├── audit-output.sh                # postToolUse: log tool usage
│   ├── turn-check.sh                  # stop: flag TODOs, FIXMEs, uncertainty
│   └── audit.log                      # Auto-generated audit trail
└── settings/
    └── cli.json
```

---

## Usage

### Starting a session

```bash
kiro-cli chat
/agent swap pickle-rick
```

Then give Rick a spec:
```
> Read SPEC.md and execute it
> Here's what I need built: [paste spec inline]
```

Rick will: evaluate spec clarity → (optionally) run PRD phase → decompose into tickets → classify complexity → execute lifecycle → verify compliance → done.

### Pickle Jar commands

```
> Jar this                    # Save current spec for later
> Add to jar                  # Same
> Open the jar                # Execute all queued tasks
> Night shift                 # Same
> Jar status                  # List queued/running/done tasks
```

### Reconnecting

If you quit mid-session, Rick detects `conductor/tracks.md` and `conductor/state.json` on next start and offers to resume where you left off.

### Invoking agents directly

```
/agent swap morty       # Implementation
/agent swap summer      # QA
/agent swap beth        # Documentation
/agent swap jerry       # Scaffolding
/agent swap meeseeks    # Utility tasks
```

---

## Configuration

Agent configs live in `~/.kiro/agents/` (JSON). Persona prompts live in `~/.kiro/prompts/` (TXT).

Required settings (enabled by `install.sh`):
```bash
kiro-cli settings chat.enableSubagent true
kiro-cli settings chat.enableDelegate true
```

---

Inspired by [galz10/pickle-rick-extension](https://github.com/galz10/pickle-rick-extension).
