# 🥒 Pickle Rick — Audit Fix Tracks
_Session: audit-fixes-2026-04-07_
_Mode: FULL_AUTONOMY_

## Progress
- Total: 10 | Done: 0 | Blocked: 0 | Pending: 10

## Tickets

### Wave 1: Critical Hook Fixes (parallel)
- [ ] **#101 — Rewrite guard-delete.sh to python3** | morty | [SIMPLE]
- [ ] **#102 — Rewrite agent-spawn.sh to python3** | morty | [SIMPLE]
- [ ] **#103 — Fix path traversal in validate-write.sh** | morty | [SIMPLE]

### Wave 2: Config Fixes (parallel)
- [ ] **#104 — Add write guard to beth.json** | meeseeks | [SIMPLE]
- [ ] **#105 — Fix pickle-rick.json allowedTools** | meeseeks | [SIMPLE]
- [ ] **#106 — Fix install.sh dead sed** | morty | [SIMPLE]
- [ ] **#107 — Remove dead code tool from morty.json** | meeseeks | [SIMPLE]

### Wave 3: Minor Hook Improvements (parallel)
- [ ] **#108 — Atomic log rotation in audit-output.sh** | morty | [SIMPLE]
- [ ] **#109 — Narrow turn-check.sh patterns** | morty | [SIMPLE]

### Wave 4: Deploy (sequential, depends on all above)
- [ ] **#110 — Sync to ~/.kiro/ and push to remote** | meeseeks | [SIMPLE]
