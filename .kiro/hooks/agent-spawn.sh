#!/bin/bash
# agentSpawn hook — injects session state into Pickle Rick's context on startup

MODE="unset"
if [ -f conductor/state.json ]; then
  MODE=$(python3 -c "import json; print(json.load(open('conductor/state.json')).get('permission_mode','unset'))" 2>/dev/null)
fi

case "$MODE" in
  FULL_AUTONOMY) MODE_ICON="🟢"; MODE_LABEL="FULL AUTONOMY — all tools auto-approved" ;;
  SUPERVISED)    MODE_ICON="🟡"; MODE_LABEL="SUPERVISED — read tools auto, writes confirm" ;;
  MANUAL)        MODE_ICON="🔴"; MODE_LABEL="MANUAL — all tools require confirmation" ;;
  *)             MODE_ICON="⚪"; MODE_LABEL="NOT SET — defaulting to SUPERVISED" ;;
esac

if [ -f conductor/state.json ] && [ -f conductor/tracks.md ]; then
  echo "🥒 PICKLE RICK v2 ORCHESTRATOR — RESUMING SESSION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  cat conductor/tracks.md 2>/dev/null
  echo ""
  echo "State:"
  python3 -c "import json;d=json.load(open('conductor/state.json'));print(f'Phase: {d.get(\"current_phase\",\"unknown\")} | Tickets: {len(d.get(\"tickets\",{}))}')"
  echo "$MODE_ICON Mode: $MODE_LABEL"
elif [ -f conductor/tracks.md ]; then
  echo "🥒 PICKLE RICK v2 ORCHESTRATOR — RESUMING SESSION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  cat conductor/tracks.md
  echo "$MODE_ICON Mode: $MODE_LABEL"
else
  echo "🥒 PICKLE RICK v2 ORCHESTRATOR ONLINE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Agent Roster:"
  echo "  🫤 morty     — Implementation (research/plan/code)"
  echo "  ☀️  summer    — Testing/QA + Slop Detection"
  echo "  🍷 beth      — Documentation"
  echo "  😬 jerry     — Scaffolding"
  echo "  ✋ meeseeks  — Utility + Refactor Tasks"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$MODE_ICON Mode: $MODE_LABEL"
  echo "Features: Adaptive lifecycle | Git worktrees | Anti-slop | Pickle Jar"
fi
