#!/bin/bash
# stop hook: check assistant response for red flags
EVENT=$(cat)
RESPONSE=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('assistant_response',''))" 2>/dev/null)
FLAGS=""
echo "$RESPONSE" | grep -qiE "TODO[:(]" && FLAGS="$FLAGS TODO"
echo "$RESPONSE" | grep -qiE "FIXME[:(]" && FLAGS="$FLAGS FIXME"
echo "$RESPONSE" | grep -qi "I'm not sure" && FLAGS="$FLAGS UNCERTAIN"
echo "$RESPONSE" | grep -qi "not implemented" && FLAGS="$FLAGS INCOMPLETE"
echo "$RESPONSE" | grep -qi '\.\.\..*implement' && FLAGS="$FLAGS STUB"
[ -n "$FLAGS" ] && echo "🥒 WARNING: Response contains red flags:$FLAGS" >&2
exit 0
