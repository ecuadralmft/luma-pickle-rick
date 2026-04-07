#!/bin/bash
# postToolUse hook: audit tool usage to log file
EVENT=$(cat)
LOG="$HOME/.kiro/hooks/audit.log"
TOOL=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name','unknown'))" 2>/dev/null)
RESULT=$(echo "$EVENT" | python3 -c "
import sys,json
e=json.load(sys.stdin)
r=e.get('tool_response',{})
s=str(r.get('result',r))[:200]
print(s)
" 2>/dev/null)
echo "[$(date -Iseconds)] $TOOL: $RESULT" >> "$LOG"
# rotate: keep last 50 lines
tail -n 50 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
exit 0
