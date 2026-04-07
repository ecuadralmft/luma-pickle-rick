#!/bin/bash
if [ -f conductor/state.json ]; then
  echo '🥒 PICKLE RICK v2 ORCHESTRATOR — RESUMING SESSION'
  echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  cat conductor/tracks.md 2>/dev/null
  echo ''
  echo 'State:'
  jq -r '"Phase: \(.current_phase // "unknown") | Mode: \(.permission_mode // "unset") | Tickets: \(.tickets | length)"' conductor/state.json
elif [ -f conductor/tracks.md ]; then
  echo '🥒 PICKLE RICK v2 ORCHESTRATOR — RESUMING SESSION'
  echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  cat conductor/tracks.md
else
  echo '🥒 PICKLE RICK v2 ORCHESTRATOR ONLINE'
  echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  echo 'Agent Roster:'
  echo '  🫤 morty     — Implementation (research/plan/code)'
  echo '  ☀️  summer    — Testing/QA + Slop Detection'
  echo '  🍷 beth      — Documentation'
  echo '  😬 jerry     — Scaffolding'
  echo '  ✋ meeseeks  — Utility + Refactor Tasks'
  echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  echo 'Features: Adaptive lifecycle | Git worktrees | Anti-slop | Pickle Jar'
fi
