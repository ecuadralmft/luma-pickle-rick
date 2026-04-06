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

| Mode | Behavior | File Deletion |
|------|----------|---------------|
| 🟢 FULL_AUTONOMY | Runs everything, reports at the end. Fix tickets created automatically. | Auto-approved silently |
| 🟡 SUPERVISED | Runs in batches per phase, shows progress, asks to continue. | Allowed with warning |
| 🔴 MANUAL | Shows each ticket before delegating, waits for approval. | Blocked until explicitly approved |

### Switching Autonomy Mid-Session

You can change the autonomy level at any time during execution:

```
> Switch to manual
> Change autonomy to supervised
> Go full auto
```

Rick updates `conductor/state.json`, announces the change, and all subsequent agent actions (including the file deletion guard) follow the new mode immediately.

### File Deletion Guard

A `preToolUse` hook (`guard-delete.sh`) intercepts any bash command containing `rm`, `rmdir`, `unlink`, or `shred` and enforces the current autonomy mode's deletion policy. This runs on every agent (morty, summer, meeseeks, and Rick himself).

---

## The Conductor System

The `conductor/` directory is Pickle Rick's brain on disk — the persistent state engine that powers the entire orchestration lifecycle. It's created automatically in your project's working directory when Rick starts a session.

### What the Conductor Does

| Capability | File | Description |
|------------|------|-------------|
| **Project Detection** | `conductor/project-context.md` | Auto-scans workspace on first run — detects language, framework, dependencies, test runner, CI/CD config. Included in every subagent's context so workers understand the codebase. |
| **PRD Drafting** | `conductor/prd.md` | When Rick detects a vague spec, he interrogates the user and produces a structured PRD (problem statement, objectives, scope, CUJs, functional requirements, risks). Skipped for clear specs. |
| **Ticket Registry** | `conductor/tracks.md` | Human-readable ticket board with status markers (`[ ]` pending, `[~]` in progress, `[x]` done, `[!]` blocked), complexity tags, retry counts, and phase groupings. |
| **Session State** | `conductor/state.json` | Machine-readable state — session ID, timestamps, permission mode, per-ticket metadata (status, lifecycle phase, worktree branch, artifact paths), phase completion tracking, and compliance scores. |
| **Per-Ticket Research** | `conductor/tickets/[id]/research.md` | Morty's codebase analysis for COMPLEX tickets — documents what exists with file:line references, data flows, constraints, and open questions. Strictly observational (what IS, not what SHOULD BE). |
| **Per-Ticket Plans** | `conductor/tickets/[id]/plan.md` | Implementation plan with specific files to modify, step-by-step changes with checkboxes, scope boundaries (in/out), and verification commands. Rick reviews for specificity before approving. |
| **Test Results** | `conductor/tickets/[id]/test-results.md` | Summer's verdict — PASS/FAIL, individual test results, edge cases tested, Slop Score (0–5), and slop findings with file:line references for Rick's refactor audit. |
| **Task Queue** | `conductor/jar/task-NNN.json` | Pickle Jar — saved specs with priority, status (queued/running/done/failed), and timestamps. Batch-executed sequentially on "open the jar". |
| **Spec Compliance** | `conductor/state.json` (compliance field) | After all tickets resolve, Rick re-reads the original spec and checks every requirement for traceability, completion, and correctness. Gaps trigger fix tickets. |

### Conductor Lifecycle

```
User gives spec
    │
    ▼
┌─────────────────────────┐
│ Project Context Scan     │──→ conductor/project-context.md
│ (auto, first run only)   │
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│ PRD Phase (if vague)     │──→ conductor/prd.md
│ Interrogate → Draft      │
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│ Decompose into Tickets   │──→ conductor/tracks.md
│ Classify SIMPLE/COMPLEX  │──→ conductor/state.json
└────────────┬────────────┘
             ▼
┌─────────────────────────┐    ┌──────────────────────────────┐
│ Execute Tickets          │──→ │ Per COMPLEX ticket:           │
│ (waves, by phase)        │    │  conductor/tickets/[id]/      │
│                          │    │    research.md → plan.md       │
│                          │    │    → implement → test-results  │
└────────────┬────────────┘    └──────────────────────────────┘
             ▼
┌─────────────────────────┐
│ Final Compliance Check   │──→ conductor/state.json (compliance)
│ Spec vs Implementation   │
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│ Report + Artifact        │──→ Ask: keep audit trail or clean up?
│ Retention Prompt         │
└─────────────────────────┘
```

### Session Resume

The conductor persists across sessions. If you quit mid-execution and come back, Rick's `agentSpawn` hook detects `conductor/state.json`, displays the current ticket board, and offers to resume where you left off. No work is lost.

### Artifact Retention

After completion, Rick asks: "Want me to keep the audit trail (`conductor/tickets/`) or clean it up?" The research, plans, and test results serve as a full audit trail of every decision made during the session.

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
│   ├── guard-delete.sh                # preToolUse: file deletion guard per autonomy mode
│   ├── audit-output.sh                # postToolUse: log tool usage
│   ├── turn-check.sh                  # stop: flag TODOs, FIXMEs, uncertainty
│   └── audit.log                      # Auto-generated audit trail
└── settings/
    └── cli.json
```

---

## Usage

### Quick Start

Pickle Rick uses your **current working directory** as the project scope — that's where `conductor/` state, `validate-write.sh` boundaries, and `.worktrees/` all live. Always `cd` into your target project folder before launching.

#### macOS / Linux

```bash
cd ~/my-project
git init                    # enables worktree isolation for COMPLEX tickets
kiro-cli chat --agent pickle-rick
```

One-liner:
```bash
(cd ~/my-project && git init && kiro-cli chat --agent pickle-rick)
```

Full autonomy (no tool confirmations):
```bash
cd ~/my-project && git init
kiro-cli chat --agent pickle-rick --trust-all-tools
```

Quick test with inline prompt:
```bash
mkdir ~/test-project && cd ~/test-project && git init
kiro-cli chat --agent pickle-rick "Build a Python CLI that converts CSV to JSON."
```

#### Windows (WSL / Ubuntu on Windows) — Recommended

Pickle Rick on Windows runs through WSL (Windows Subsystem for Linux). Open your WSL terminal (search "Ubuntu" in Start menu, or run `wsl` from PowerShell).

**Using a WSL-native project folder (best performance):**
```bash
cd ~/my-project
git init
kiro-cli chat --agent pickle-rick
```

**Accessing a Windows folder from WSL (works with OneDrive, Desktop, etc.):**
```bash
# Windows paths are available under /mnt/c/ — always quote paths with spaces
cd "/mnt/c/Users/YourName/OneDrive - Company/Projects/my-project"
git init
kiro-cli chat --agent pickle-rick --trust-all-tools
```

Full autonomy from a Windows folder:
```bash
cd "/mnt/c/Users/YourName/Documents/my-project"
git init
kiro-cli chat --agent pickle-rick --trust-all-tools
```

> **⚠️ Windows paths in WSL:**
> - Windows drives are mounted at `/mnt/c/`, `/mnt/d/`, etc.
> - **Always quote paths with spaces:** `cd "/mnt/c/Users/You/OneDrive - Company/folder"`
> - Performance is slower on `/mnt/c/` than WSL-native `~/` paths — for large projects, consider cloning into `~/`
> - OneDrive folders work fine — just use the full `/mnt/c/` path with quotes

#### Windows (PowerShell — native, no WSL)

If kiro-cli is installed natively on Windows without WSL:

```powershell
# IMPORTANT: Always quote paths that contain spaces
mkdir "$HOME\my-project"
cd "$HOME\my-project"
git init
kiro-cli chat --agent pickle-rick
```

Full autonomy:
```powershell
cd "$HOME\my-project"
git init
kiro-cli chat --agent pickle-rick --trust-all-tools
```

> **⚠️ PowerShell gotchas:**
> - **Paths with spaces MUST be quoted:** `cd "C:\Users\You\OneDrive - Company\project"` — without quotes, PowerShell treats spaces as argument separators and you'll get `ParameterBindingException`
> - **Don't chain `cd` with `;`:** If `cd` fails, the next command still runs in the wrong directory. Use separate lines.
> - **`mkdir` first:** Unlike bash, `cd` to a non-existent folder gives `PathNotFound`. Create it first.
> - **Hooks require bash:** Install [Git for Windows](https://git-scm.com/download/win) (includes Git Bash) or use WSL.

#### Swap to Pickle Rick inside an existing chat

```
/agent swap pickle-rick
```
Or use the keyboard shortcut: `Ctrl+Shift+P`

The `--trust-all-tools` flag skips ALL tool confirmation prompts at the CLI level. Combined with choosing 🟢 FULL_AUTONOMY inside the session, this is fully hands-off execution.

### Giving Rick a spec

Once in a session, give Rick something to work with:
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

## Installation

### Prerequisites

| Dependency | Required | How to install |
|------------|----------|----------------|
| **Kiro CLI** | ✅ Yes | [kiro.dev](https://kiro.dev) — follow the install guide for your platform |
| **Git** | ✅ Yes | macOS: `brew install git` or `xcode-select --install`<br>Linux: `sudo apt install git` (Ubuntu/Debian) or `sudo yum install git` (RHEL/Fedora)<br>Windows: [git-scm.com/download/win](https://git-scm.com/download/win) — use the installer, includes Git Bash |
| **Python 3** | ✅ Yes | macOS: `brew install python3` (or pre-installed on most Macs)<br>Linux: `sudo apt install python3` (usually pre-installed)<br>Windows: [python.org/downloads](https://www.python.org/downloads/) — check "Add to PATH" during install |

> **Why Git?** Pickle Rick uses git for worktree isolation (each COMPLEX ticket runs in its own branch), diff auditing (Rick reads `git diff` to find slop), and revert safety (blocked tickets get reverted). Without git, Rick falls back to single-directory mode with a warning — worktrees and diff-based refactoring are disabled.

### macOS / Linux

```bash
git clone https://github.com/ecuadralmft/luma-pickle-rick.git
cd luma-pickle-rick
./install.sh
```

### Windows (WSL / Ubuntu on Windows) — Recommended

```bash
# Run inside your WSL terminal
git clone https://github.com/ecuadralmft/luma-pickle-rick.git
cd luma-pickle-rick
./install.sh
```

### Windows (PowerShell — native, no WSL)

```powershell
git clone https://github.com/ecuadralmft/luma-pickle-rick.git
cd luma-pickle-rick
bash install.sh    # requires Git Bash or bash in PATH
```

> **Note:** The hooks are bash scripts. On native Windows without WSL, install [Git for Windows](https://git-scm.com/download/win) (includes Git Bash) to get bash in your PATH. WSL is the recommended approach for Windows users.

The installer copies agents, prompts, and hooks to `~/.kiro/` and enables the required settings.

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

---

## ⚖️ Disclaimer

By downloading, installing, or using this agent, you agree to the following terms:

This software is provided "as is", without warranty of any kind, express or implied. The "Pickle Rick" persona is a fictional character used for creative and entertainment purposes within an engineering workflow. The persona's voice, tone, and opinions are stylistic choices and do not reflect the views, values, or opinions of the creator(s).

**All actions performed by this agent — including but not limited to code generation, file modifications, shell command execution, and architectural decisions — are the direct result of the user's prompts, inputs, and configuration choices.** The agent operates exclusively under user direction. Neither the persona nor its creator(s) bear responsibility for the output, consequences, or side effects of the agent's actions.

**You are solely responsible for:**
- Reviewing all code and changes produced by the agent before committing or deploying
- Ensuring the agent operates in an appropriate environment (sandboxed, version-controlled)
- Any modifications the agent makes to your filesystem, repositories, or infrastructure

Use at your own risk. Always run in a controlled environment and review changes before shipping.
