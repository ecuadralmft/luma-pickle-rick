#!/bin/bash
# 🥒 Pickle Rick Multi-Agent Orchestrator — Installer for Kiro CLI
set -e

KIRO_DIR="$HOME/.kiro"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🥒 I'M PICKLE RICK! Installing the orchestrator..."
echo ""

# Create directories
mkdir -p "$KIRO_DIR/agents" "$KIRO_DIR/prompts" "$KIRO_DIR/hooks"

# Copy prompts
cp "$SCRIPT_DIR/prompts/"*.txt "$KIRO_DIR/prompts/"
echo "  ✓ Prompts installed to $KIRO_DIR/prompts/"

# Copy hooks and make executable
cp "$SCRIPT_DIR/hooks/"*.sh "$KIRO_DIR/hooks/"
chmod +x "$KIRO_DIR/hooks/"*.sh
echo "  ✓ Hooks installed to $KIRO_DIR/hooks/"

# Patch agent configs with correct home directory and copy
for f in "$SCRIPT_DIR/agents/"*.json; do
    BASENAME=$(basename "$f")
    sed "s|file://KIRO_HOME/|file://$KIRO_DIR/|g" "$f" > "$KIRO_DIR/agents/$BASENAME"
done
echo "  ✓ Agents installed to $KIRO_DIR/agents/"

# Enable required settings
SETTINGS_DIR="$KIRO_DIR/settings"
SETTINGS_FILE="$SETTINGS_DIR/cli.json"
mkdir -p "$SETTINGS_DIR"
if [ -f "$SETTINGS_FILE" ]; then
    # Merge into existing settings using python
    python3 -c "
import json
with open('$SETTINGS_FILE') as f: s=json.load(f)
s['chat.enableSubagent']=True
s['chat.enableDelegate']=True
with open('$SETTINGS_FILE','w') as f: json.dump(s,f,indent=2)
print('  ✓ Settings updated (merged with existing)')
"
else
    echo '{"chat.enableSubagent":true,"chat.enableDelegate":true}' > "$SETTINGS_FILE"
    echo "  ✓ Settings created"
fi

# Install MCP tools (GitPulse + Obsidian Memory)
MCP_TOOLS_DIR="$HOME/luma-mcp-tools"
MCP_TOOLS_REPO="https://github.com/ecuadralmft/luma-mcp-tools.git"
if [ -d "$MCP_TOOLS_DIR" ]; then
    echo "  ✓ luma-mcp-tools already cloned at $MCP_TOOLS_DIR"
else
    echo "  Cloning luma-mcp-tools..."
    git clone "$MCP_TOOLS_REPO" "$MCP_TOOLS_DIR"
    echo "  ✓ Cloned luma-mcp-tools"
fi
echo "  Running MCP tools installer..."
bash "$MCP_TOOLS_DIR/install.sh"

echo ""
echo "🥒 Installation complete! Restart Kiro CLI, then:"
echo "   kiro-cli chat"
echo "   (Pickle Rick loads automatically from your system prompt)"
