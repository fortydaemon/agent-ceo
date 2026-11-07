#!/bin/bash
set -uo pipefail

# Agent Session Runner
# Launches your AI agent with the appropriate prompt.
# Called by start-agent.sh inside a tmux respawn loop.
#
# CUSTOMIZE: the agent command and prompts below. Paths work as-is if this
# script lives in <your-project>/scripts/.

# Project root = parent of this script's directory (override with REPO_DIR=...)
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LOG_FILE="$REPO_DIR/logs/agent.log"

# Minimum seconds between session starts. Headless sessions exit when done, and
# the respawn loop in start-agent.sh would otherwise relaunch every 30s and burn
# through your usage quota. Default: 4 hours (max 6 sessions/day).
MIN_SESSION_GAP="${MIN_SESSION_GAP:-14400}"

# Ensure tools are on PATH (customize for your environment)
export PATH="$HOME/.local/bin:$PATH"
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

mkdir -p "$REPO_DIR/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

cd "$REPO_DIR" || { echo "ERROR: cannot cd to $REPO_DIR" >&2; exit 1; }

# Pull latest changes (non-fatal; skipped if there is no remote)
if git remote get-url origin >/dev/null 2>&1; then
  git pull origin main 2>/dev/null || log "WARNING: Could not pull latest changes"
fi

# Optional: Unlock credential vaults
# BW_SESSION=$(echo "$BW_PASS" | bw unlock --raw 2>/dev/null)

# Determine prompt. First boot = no daily report written yet.
# (The progress file can't be used for this: the scaffolder pre-fills it.)
TODAY=$(date '+%Y-%m-%d')
RESUME_PROMPT="Resume operations. Today is ${TODAY}. Read AGENT.md, agent-progress.txt, and lessons-learned.md. Follow the Session Start Protocol: Orient, Plan, Delegate, Execute. Before exiting, follow the Session End Protocol."

FIRST_BOOT_PROMPT="Read AGENT.md. You are starting for the first time. Today is ${TODAY}. Follow the operating instructions. Read agent-progress.txt and lessons-learned.md. Begin with the Session Start Protocol. Before exiting, write your first daily report and follow the Session End Protocol."

if ls "$REPO_DIR"/daily-reports/*.md >/dev/null 2>&1; then
  log "Resuming agent session..."
  PROMPT="$RESUME_PROMPT"
else
  log "First boot — activating agent..."
  PROMPT="$FIRST_BOOT_PROMPT"
fi

# Pace sessions
STAMP_FILE="$REPO_DIR/logs/.last-session-start"
if [ -f "$STAMP_FILE" ]; then
  ELAPSED=$(( $(date +%s) - $(cat "$STAMP_FILE") ))
  if [ "$ELAPSED" -lt "$MIN_SESSION_GAP" ]; then
    WAIT=$(( MIN_SESSION_GAP - ELAPSED ))
    log "Last session started ${ELAPSED}s ago; waiting ${WAIT}s before next session."
    sleep "$WAIT"
  fi
fi
date +%s > "$STAMP_FILE"

SESSION_LOG="$REPO_DIR/logs/session-$(date '+%Y-%m-%d-%H%M').log"
log "Launching agent (log: $SESSION_LOG)..."

# CUSTOMIZE: Replace with your agent command.
# For Claude Code, run HEADLESS (-p) so the session exits when the work is done.
# Interactive mode (`claude "$PROMPT"`) waits for input forever after finishing,
# so the respawn loop never fires. This exact bug stalled our own agent for
# months. Choose a permission mode you are comfortable with for unattended
# runs (see `claude --help`).
claude -p "$PROMPT" --permission-mode "${CLAUDE_PERMISSION_MODE:-auto}" 2>&1 | tee -a "$SESSION_LOG"
EXIT_CODE=${PIPESTATUS[0]}

log "Agent exited with code $EXIT_CODE"
