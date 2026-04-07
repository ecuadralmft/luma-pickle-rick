#!/bin/bash
# preToolUse hook: guard file deletion based on autonomy mode
# Reads conductor/state.json for permission_mode
# FULL_AUTONOMY: allow deletions silently
# SUPERVISED: warn but allow
# MANUAL: block and require explicit approval
EVENT=$(cat)

# Extract the bash command from execute_bash tool input
CMD=$(echo "$EVENT" | python3 -c "
import sys,json
e=json.load(sys.stdin)
ti=e.get('tool_input',{})
print(ti.get('command',''))
" 2>/dev/null)

[ -z "$CMD" ] && exit 0

# Check if command involves file deletion
IS_DELETE=$(echo "$CMD" | grep -iE '\brm\b|rmdir|unlink|shred' || true)
[ -z "$IS_DELETE" ] && exit 0

# Read permission mode from conductor/state.json
CWD=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)
MODE=$(python3 -c "
import json,os
p=os.path.join('${CWD}','conductor','state.json')
if os.path.exists(p):
    with open(p) as f: print(json.load(f).get('permission_mode','SUPERVISED'))
else:
    print('SUPERVISED')
" 2>/dev/null)

case "$MODE" in
    FULL_AUTONOMY)
        # Allow silently
        exit 0
        ;;
    SUPERVISED)
        echo "🥒 WARNING: File deletion detected in command: $CMD" >&2
        echo "   Mode: SUPERVISED — allowing with warning." >&2
        exit 0
        ;;
    MANUAL|*)
        echo "🥒 BLOCKED: File deletion requires approval in MANUAL mode." >&2
        echo "   Command: $CMD" >&2
        echo "   Change autonomy level or approve this action explicitly." >&2
        exit 2
        ;;
esac
