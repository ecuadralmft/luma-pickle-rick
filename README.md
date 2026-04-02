# 🥒 Pickle Rick Multi-Agent Orchestrator

A reusable, persona-driven multi-agent system for Kiro CLI. Pickle Rick reads any spec document, decomposes it into tickets, and delegates work to a themed Rick & Morty agent crew — with proactive monitoring via hooks.

Inspired by the [Gemini CLI persona extension pattern](https://aipositive.substack.com/p/from-tool-to-teammate-crafting-ai), adapted natively for Kiro's agent + subagent + hooks architecture.

## Installation

```bash
git clone https://github.com/ecuadralmft/luma-pickle-rick.git
cd luma-pickle-rick
./install.sh
```

The installer copies agents, prompts, and hooks to `~/.kiro/` (global scope — works across all workspaces) and enables the required settings.

## Quick Start

```bash
# 1. Restart Kiro CLI (settings need a fresh session)
kiro-cli chat

# 2. Switch to Pickle Rick (or press Ctrl+Shift+P)
/agent pickle-rick

# 3. Point at any spec document
> Read SPEC.md and execute it
```

## Agent Roster

| Agent | Shortcut | Role | Persona |
|-------|----------|------|---------|
| 🥒 pickle-rick | Ctrl+Shift+P | Orchestrator — reads specs, creates tickets, delegates, monitors | Brash genius scientist |
| 🫤 morty | Ctrl+Shift+1 | Implementation — writes functions, modules, business logic | Nervous but capable coder |
| ☀️ summer | Ctrl+Shift+2 | Testing/QA — writes tests, finds edge cases | Blunt, critical QA engineer |
| 🍷 beth | Ctrl+Shift+3 | Documentation — READMEs, code review, docs | Precise technical writer |
| 😬 jerry | Ctrl+Shift+4 | Scaffolding — directory structures, config files | Enthusiastic about simple tasks |
| ✋ meeseeks | Ctrl+Shift+5 | Utility — one-off tasks, quick fixes | Existentially urgent, does one thing |

## How It Works

1. **You** point Pickle Rick at a spec document
2. **Pickle Rick** reads it, decomposes into tickets, assigns to agents
3. **Workers** execute in parallel (up to 4 via `use_subagent`) or async (`delegate`)
4. **Hooks** monitor quality: block bad writes, audit tool usage, flag red flags
5. **Pickle Rick** reviews output, re-delegates if needed, reports final summary

## Hooks (Guardrails)

| Hook | Type | What It Does |
|------|------|-------------|
| `validate-write.sh` | preToolUse | Blocks `fs_write` outside the project directory (exit 2) |
| `audit-output.sh` | postToolUse | Logs tool name + result to `~/.kiro/hooks/audit.log` |
| `turn-check.sh` | stop | Warns if response contains TODO, FIXME, or uncertainty |

## Adding a New Worker Agent

1. Create a prompt file: `~/.kiro/prompts/your-agent.txt`
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
│   ├── pickle-rick.txt     # Orchestrator persona
│   ├── morty.txt           # Morty persona
│   ├── summer.txt          # Summer persona
│   ├── beth.txt            # Beth persona
│   ├── jerry.txt           # Jerry persona
│   └── meeseeks.txt        # Meeseeks persona
├── hooks/
│   ├── validate-write.sh   # preToolUse: block out-of-scope writes
│   ├── audit-output.sh     # postToolUse: log tool usage
│   ├── turn-check.sh       # stop: flag red flags
│   └── audit.log           # Auto-generated audit trail
└── README-pickle-rick.md   # This file
```

## Required Settings

```bash
kiro-cli settings chat.enableSubagent true
kiro-cli settings chat.enableDelegate true
```
