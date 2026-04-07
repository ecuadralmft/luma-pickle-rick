#!/bin/bash
# preToolUse hook: guard file deletion based on autonomy mode
# Reads conductor/state.json for permission_mode
# FULL_AUTONOMY: allow silently | SUPERVISED: warn but allow | MANUAL: block
EVENT=$(cat)

CMD=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)
[ -z "$CMD" ] && exit 0

echo "$CMD" | grep -qiE '\brm\b|rmdir|unlink|shred' || exit 0

CWD=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)
STATE="${CWD:+$CWD/}conductor/state.json"
MODE=$([ -f "$STATE" ] && python3 -c "import json; print(json.load(open('$STATE')).get('permission_mode','SUPERVISED'))" 2>/dev/null || echo "SUPERVISED")

case "$MODE" in
    FULL_AUTONOMY)
        exit 0
        ;;
    SUPERVISED)
        echo "🥒 WARNING: File deletion detected: $CMD" >&2
        echo "   Mode: SUPERVISED — allowing with warning." >&2
        exit 0
        ;;
    MANUAL|*)
        echo "🥒 BLOCKED: File deletion requires approval in MANUAL mode." >&2
        echo "   Command: $CMD" >&2
        exit 2
        ;;
esac
