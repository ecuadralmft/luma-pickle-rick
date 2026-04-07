#!/bin/bash
# preToolUse hook: guard file deletion based on autonomy mode
# Reads conductor/state.json for permission_mode
# FULL_AUTONOMY: allow silently | SUPERVISED: warn but allow | MANUAL: block
EVENT=$(cat)

CMD=$(echo "$EVENT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

echo "$CMD" | grep -qiE '\brm\b|rmdir|unlink|shred' || exit 0

CWD=$(echo "$EVENT" | jq -r '.cwd // empty')
STATE="${CWD:+$CWD/}conductor/state.json"
MODE=$([ -f "$STATE" ] && jq -r '.permission_mode // "SUPERVISED"' "$STATE" || echo "SUPERVISED")

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
