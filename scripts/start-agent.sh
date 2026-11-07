#!/bin/bash
set -uo pipefail

# Agent Environment Launcher
# Starts a tmux session with auto-respawning agent.
# The agent automatically restarts after exit with a 30-second cooldown
# (run-agent.sh additionally enforces MIN_SESSION_GAP between sessions).
#
# Usage:
#   ./scripts/start-agent.sh          # Start and attach
#   ./scripts/start-agent.sh --detach # Start without attaching (for systemd/cron)
#   tmux attach-session -t agent      # Observe the running agent
#   tmux kill-session -t agent        # Emergency stop

# Project root = parent of this script's directory (override with REPO_DIR=...)
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SESSION_NAME="${SESSION_NAME:-agent}"
RUN_SCRIPT="$REPO_DIR/scripts/run-agent.sh"
DETACH=false

[ "${1:-}" = "--detach" ] && DETACH=true

if ! command -v tmux >/dev/null 2>&1; then
  echo "ERROR: tmux is required (apt install tmux / brew install tmux)"
  exit 1
fi

# If session already exists, just attach (or exit if detached)
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  if [ "$DETACH" = true ]; then
    echo "Agent session already running."
    exit 0
  fi
  echo "Agent session already running. Attaching..."
  exec tmux attach-session -t "$SESSION_NAME"
fi

echo "Starting Agent Environment..."

if [ ! -d "$REPO_DIR" ]; then
  echo "ERROR: Repo not found at $REPO_DIR"
  exit 1
fi

if [ ! -x "$RUN_SCRIPT" ]; then
  echo "ERROR: Runner script not found or not executable: $RUN_SCRIPT"
  echo "       Try: chmod +x \"$REPO_DIR\"/scripts/*.sh"
  exit 1
fi

mkdir -p "$REPO_DIR/logs"
touch "$REPO_DIR/logs/agent.log"

# Quote paths for the tmux shell command (handles spaces in REPO_DIR)
Q_RUN=$(printf '%q' "$RUN_SCRIPT")
Q_LOG=$(printf '%q' "$REPO_DIR/logs/agent.log")

# Start tmux session with auto-respawning agent
if ! tmux new-session -d -s "$SESSION_NAME" -n main -c "$REPO_DIR" \
  "while true; do $Q_RUN; echo '--- Agent exited. Restarting in 30s (Ctrl+C to stop) ---'; sleep 30; done"; then
  echo "ERROR: failed to start tmux session '$SESSION_NAME'"
  exit 1
fi

# Utility windows
tmux new-window -t "$SESSION_NAME" -n logs -c "$REPO_DIR" "tail -F $Q_LOG"
tmux new-window -t "$SESSION_NAME" -n shell -c "$REPO_DIR"

tmux select-window -t "$SESSION_NAME":main

echo "Agent Environment started."

if [ "$DETACH" = false ]; then
  exec tmux attach-session -t "$SESSION_NAME"
fi
