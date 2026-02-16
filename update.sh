#!/bin/bash
# claude-code-handoff — Update
# Usage: curl -fsSL https://raw.githubusercontent.com/eximIA-Ventures/claude-code-handoff/main/update.sh | bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

REPO="eximIA-Ventures/claude-code-handoff"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
PROJECT_DIR="$(pwd)"
CLAUDE_DIR="$PROJECT_DIR/.claude"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  claude-code-handoff — Update${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Project: ${GREEN}$PROJECT_DIR${NC}"
echo ""

# Check if installed
if [ ! -d "$CLAUDE_DIR/commands" ] || [ ! -f "$CLAUDE_DIR/commands/resume.md" ]; then
  echo -e "  ${RED}claude-code-handoff is not installed in this project.${NC}"
  echo -e "  Run: npx claude-code-handoff"
  exit 1
fi

# Detect if running from cloned repo or via curl
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null)" 2>/dev/null && pwd 2>/dev/null || echo "")"

download_file() {
  local src="$1"
  local dst="$2"
  if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$src" ]; then
    cp "$SCRIPT_DIR/$src" "$dst"
  else
    curl -fsSL "$RAW_BASE/$src" -o "$dst"
  fi
}

# 1. Update commands
echo -e "  ${YELLOW}[1/3]${NC} Updating commands..."
download_file "commands/handoff.md" "$CLAUDE_DIR/commands/handoff.md"
download_file "commands/resume.md" "$CLAUDE_DIR/commands/resume.md"
download_file "commands/save-handoff.md" "$CLAUDE_DIR/commands/save-handoff.md"
download_file "commands/switch-context.md" "$CLAUDE_DIR/commands/switch-context.md"

# 2. Update rules
echo -e "  ${YELLOW}[2/3]${NC} Updating rules..."
download_file "rules/session-continuity.md" "$CLAUDE_DIR/rules/session-continuity.md"

# 3. Remove legacy Portuguese commands if present
echo -e "  ${YELLOW}[3/3]${NC} Cleaning up legacy files..."
CLEANED=0
for f in retomar.md salvar-handoff.md trocar-contexto.md; do
  if [ -f "$CLAUDE_DIR/commands/$f" ]; then
    rm -f "$CLAUDE_DIR/commands/$f"
    CLEANED=$((CLEANED + 1))
  fi
done

echo ""
echo -e "${GREEN}  Updated successfully!${NC}"
if [ "$CLEANED" -gt 0 ]; then
  echo -e "  Removed $CLEANED legacy command(s)"
fi
echo ""
echo -e "  Handoff data in .claude/handoffs/ was ${CYAN}not touched${NC}."
echo ""
