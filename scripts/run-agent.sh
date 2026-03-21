#!/bin/bash
set -uo pipefail

# Agent Session Runner
# Launches your AI agent with the appropriate prompt.
# Called by start-agent.sh inside a tmux respawn loop.
#
# CUSTOMIZE: Set REPO_DIR, AGENT_CMD, and the prompts below.

REPO_DIR=~/dev/your-project
LOG_FILE="$REPO_DIR/logs/agent.log"

# Ensure tools are on PATH (customize for your environment)
export PATH="$HOME/.local/bin:$PATH"
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

mkdir -p "$REPO_DIR/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

cd "$REPO_DIR"

# Pull latest changes (non-fatal)
git pull origin main 2>/dev/null || log "WARNING: Could not pull latest changes"

# Optional: Unlock credential vaults
# BW_SESSION=$(echo "$BW_PASS" | bw unlock --raw 2>/dev/null)

# Determine prompt
TODAY=$(date '+%Y-%m-%d')
RESUME_PROMPT="Resume operations. Today is ${TODAY}. Read AGENT.md, agent-progress.txt, and lessons-learned.md. Follow the Session Start Protocol: Orient, Plan, Delegate, Execute."

FIRST_BOOT_PROMPT="Read AGENT.md. You are starting for the first time. Follow the operating instructions. Read agent-progress.txt and lessons-learned.md. Begin with the Session Start Protocol."

if [ -f "$REPO_DIR/agent-progress.txt" ] && [ -s "$REPO_DIR/agent-progress.txt" ]; then
  log "Resuming agent session..."
  PROMPT="$RESUME_PROMPT"
else
  log "First boot — activating agent..."
  PROMPT="$FIRST_BOOT_PROMPT"
fi

log "Launching agent..."

# CUSTOMIZE: Replace with your agent command
# For Claude Code:
claude "$PROMPT"
# For other agents, replace with appropriate command

EXIT_CODE=$?
log "Agent exited with code $EXIT_CODE"
