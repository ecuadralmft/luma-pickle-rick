#!/bin/bash
# preToolUse hook: block fs_write outside CWD
EVENT=$(cat)
CWD=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)
PATHS=$(echo "$EVENT" | python3 -c "
import sys,json
e=json.load(sys.stdin)
ti=e.get('tool_input',{})
ops=ti.get('operations',[]) if isinstance(ti,dict) else []
# fs_write uses 'path' directly
p=ti.get('path','')
if p: print(p)
for o in ops:
    pp=o.get('path','')
    if pp: print(pp)
" 2>/dev/null)

[ -z "$CWD" ] && exit 0
while IFS= read -r fp; do
    [ -z "$fp" ] && continue
    case "$fp" in
        "$CWD"/*|"$CWD") ;;
        /*) echo "🥒 BLOCKED: Write to '$fp' is outside project scope ($CWD)" >&2; exit 2 ;;
    esac
done <<< "$PATHS"
exit 0
