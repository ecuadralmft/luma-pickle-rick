# 🥒 Pickle Rick Multi-Agent Orchestrator

A reusable, persona-driven multi-agent orchestrator for [Kiro CLI](https://kiro.dev). Pickle Rick reads any spec document, decomposes it into phased tickets, delegates work to a themed Rick & Morty agent crew, iteratively verifies quality, and produces a spec compliance report — all with proactive monitoring via hooks.

Inspired by the [Gemini CLI Conductor extension](https://github.com/gemini-cli-extensions/conductor) and the [persona extension pattern](https://aipositive.substack.com/p/from-tool-to-teammate-crafting-ai), adapted natively for Kiro's agent + subagent + hooks architecture.

                                                                    ᵇʸ ᵉᵈᵈⁱᵉ

## Installation

```bash
git clone https://github.com/ecuadralmft/luma-pickle-rick.git
cd luma-pickle-rick
./install.sh
```

The installer copies agents, prompts, and hooks to `~/.kiro/` (global scope — works across all workspaces), patches file paths for your system, and enables the required settings.

## Quick Start

```bash
# 1. Restart Kiro CLI (settings need a fresh session)
kiro-cli chat

# 2. Switch to Pickle Rick
/agent swap pickle-rick
# or press Ctrl+Shift+P

# 3. Point at any spec document
> Read SPEC.md and execute it
```

## Invoking Pickle Rick

### Option 1: Slash Command
```
/agent swap pickle-rick
```

### Option 2: Keyboard Shortcut
Press `Ctrl+Shift+P` during any Kiro CLI session to toggle Pickle Rick on/off.

### Option 3: Set as Default Agent
```bash
kiro-cli settings chat.defaultAgent pickle-rick
```

### Invoking Worker Agents Directly
```
/agent swap morty       # or Ctrl+Shift+1 — Implementation
/agent swap summer      # or Ctrl+Shift+2 — Testing/QA
/agent swap beth        # or Ctrl+Shift+3 — Documentation
/agent swap jerry       # or Ctrl+Shift+4 — Scaffolding
/agent swap meeseeks    # or Ctrl+Shift+5 — Utility tasks
```

### Example Prompts
```
> Read SPEC.md and execute it
> Read docs/requirements.md and build it
> Here's what I need built: [paste spec inline]
> Check status on the current work
```

## Agent Roster

| Agent | Shortcut | Role | Persona |
|-------|----------|------|---------|
| 🥒 pickle-rick | Ctrl+Shift+P | Orchestrator — reads specs, creates tickets, delegates, monitors | Brash genius scientist |
| 🫤 morty | Ctrl+Shift+1 | Implementation — writes functions, modules, business logic | Nervous but capable coder |
| ☀️ summer | Ctrl+Shift+2 | Testing/QA — writes tests, finds edge cases | Blunt, critical QA engineer |
| 🍷 beth | Ctrl+Shift+3 | Documentation — READMEs, code review, doc sync | Precise technical writer |
| 😬 jerry | Ctrl+Shift+4 | Scaffolding — directory structures, config files | Enthusiastic about simple tasks |
| ✋ meeseeks | Ctrl+Shift+5 | Utility — one-off tasks, quick fixes | Existentially urgent, does one thing |

## How It Works

```
You ──► SPEC.md ──► 🥒 Pickle Rick
                        │
                        ├─ 1. Scans workspace (language, framework, structure)
                        ├─ 2. Reads spec, decomposes into phased tickets
                        ├─ 3. Writes conductor/tracks.md (persistent state)
                        ├─ 4. Permission checkpoint (you pick trust level)
                        │
                        ├─ Phase 1: 😬 Jerry ── scaffolding
                        │     └─ ✅ Phase verification
                        ├─ Phase 2: 🫤 Morty ── implementation
                        │     ├─ ☀️ Summer verifies each ticket
                        │     ├─ 🔄 Retry loop (max 3) on failures
                        │     └─ ✅ Phase verification
                        ├─ Phase 3: ☀️ Summer ── additional test suites
                        │     └─ ✅ Phase verification
                        ├─ Phase 4: 🍷 Beth ── documentation + doc sync
                        │     └─ ✅ Phase verification
                        │
                        ├─ 📋 Final spec compliance review
                        └─ 📊 Damage report
```

## Orchestration Features

### Permission System
Before executing any work, Pickle Rick asks you to choose a trust level:

| Mode | Behavior |
|------|----------|
| 🟢 **Full Autonomy** | Runs everything, trusts all agents, reports at the end |
| 🟡 **Supervised** | Runs in batches per phase, shows progress, asks to continue |
| 🔴 **Manual** | Shows each ticket before delegating, waits for your greenlight |

The chosen permission mode **cascades to all subagents** — workers adjust their verbosity and confirmation behavior accordingly.

### Iterative Verification Loop
Every implementation ticket follows this cycle:
1. **Morty** writes the code
2. **Summer** verifies against acceptance criteria → PASS or FAIL
3. On FAIL: Morty gets re-delegated with failure details (max 3 retries)
4. After 3 failures: ticket marked **blocked**, git revert offered

### Phase Verification Checkpoints
After all tickets in a phase complete, Pickle Rick verifies the phase as a whole:
- **Scaffolding**: checks directories/files exist
- **Implementation**: checks code files exist, runs basic lint/compile
- **Testing**: checks tests ran, reports pass/fail counts
- **Documentation**: checks doc files exist and reference correct modules

### Persistent Tracks (Pause/Resume)
Ticket state is written to `conductor/tracks.md` in your workspace:
```markdown
# 🥒 Pickle Rick — Track Registry
## Tickets
- [x] **#1 — Project scaffolding** | jerry | Phase: scaffolding
- [~] **#2 — Core module** | morty | Phase: implementation
- [ ] **#3 — Unit tests** | summer | Phase: testing
```
If you quit mid-session and come back, Pickle Rick detects the file and offers to resume.

### Project Context Scan
On first run in a workspace, Pickle Rick auto-detects:
- Language and framework (from package.json, requirements.txt, Cargo.toml, etc.)
- Existing project structure
- Dependencies and test framework
- CI/CD configuration

This context is written to `conductor/project-context.md` and passed to every subagent so workers match your project's conventions.

### Final Spec Compliance Review
After all tickets complete, Pickle Rick re-reads the original spec and produces:

| Requirement | Ticket | Status | Compliant? |
|-------------|--------|--------|------------|
| CSV input   | #2     | ✅ done | ✅ Yes     |
| Rate limit  | #3     | ✅ done | ⚠️ Partial |
| Retry logic | #4     | ❌ blocked | ❌ No   |

With actionable recommendations for any gaps.

### Git-Aware Revert
When a ticket is blocked after 3 retries, Pickle Rick:
1. Finds commits made during that ticket's execution
2. Asks if you want to revert them (unless Full Autonomy)
3. Runs `git revert` to clean up

### Doc Sync
Beth (documentation agent) automatically updates README.md and project-context.md to reflect what was actually built — no manual doc maintenance needed.

## Hooks (Guardrails)

| Hook | Type | What It Does |
|------|------|-------------|
| `validate-write.sh` | preToolUse | Blocks `fs_write` outside the project directory (exit 2) |
| `audit-output.sh` | postToolUse | Logs tool name + result to `~/.kiro/hooks/audit.log` |
| `turn-check.sh` | stop | Warns if response contains TODO, FIXME, or uncertainty |

## Workspace Artifacts

When Pickle Rick runs in a workspace, it creates:
```
your-project/
├── conductor/
│   ├── tracks.md            # Ticket registry (source of truth)
│   └── project-context.md   # Auto-detected project context
├── SPEC.md                  # Your input spec (you provide this)
└── ... (your project files)
```

## Adding a New Worker Agent

1. Create a prompt file: `~/.kiro/prompts/your-agent.txt`
   - Include VOICE, EXPERTISE, CONSTRAINTS, PERMISSION RULES, PROJECT CONTEXT, SCOPE ENFORCEMENT, and OUTPUT FORMAT sections
2. Create an agent config: `~/.kiro/agents/your-agent.json`
3. Add the agent name to `pickle-rick.json` → `toolsSettings.subagent.availableAgents` and `trustedAgents`
4. Validate: `kiro-cli agent validate --path ~/.kiro/agents/your-agent.json`

## File Structure

```
~/.kiro/
├── agents/
│   ├── pickle-rick.json    # Orchestrator
│   ├── morty.json          # Implementation
│   ├── summer.json         # Testing/QA
│   ├── beth.json           # Documentation
│   ├── jerry.json          # Scaffolding
│   └── meeseeks.json       # Utility
├── prompts/
│   ├── pickle-rick.txt     # Orchestrator persona + orchestration logic
│   ├── morty.txt           # Morty persona
│   ├── summer.txt          # Summer persona
│   ├── beth.txt            # Beth persona + doc sync
│   ├── jerry.txt           # Jerry persona
│   └── meeseeks.txt        # Meeseeks persona
├── hooks/
│   ├── validate-write.sh   # preToolUse: block out-of-scope writes
│   ├── audit-output.sh     # postToolUse: log tool usage
│   ├── turn-check.sh       # stop: flag red flags
│   └── audit.log           # Auto-generated audit trail
└── settings/
    └── cli.json            # enableSubagent + enableDelegate
```

## Required Settings

```bash
kiro-cli settings chat.enableSubagent true
kiro-cli settings chat.enableDelegate true
```

The `install.sh` script enables these automatically.

## Verifying the Installation

```bash
# List all agents — should show pickle-rick + 5 workers
kiro-cli agent list

# Validate a specific agent config
kiro-cli agent validate --path ~/.kiro/agents/pickle-rick.json

# Check hooks are working
echo '{"hook_event_name":"preToolUse","cwd":"/tmp","tool_name":"fs_write","tool_input":{"path":"/etc/bad"}}' \
  | ~/.kiro/hooks/validate-write.sh
# Should print: 🥒 BLOCKED and exit code 2

# View the audit trail after a session
cat ~/.kiro/hooks/audit.log
```
