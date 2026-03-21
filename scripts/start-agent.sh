#!/bin/bash
set -uo pipefail

# Agent Environment Launcher
# Starts a tmux session with auto-respawning agent.
# The agent automatically restarts after exit with a 30-second cooldown.
#
# Usage:
#   ./start-agent.sh          # Start and attach
#   ./start-agent.sh --detach # Start without attaching (for systemd/cron)
#   tmux attach-session -t agent  # Observe the running agent
#   tmux kill-session -t agent    # Emergency stop

REPO_DIR=~/dev/your-project  # CUSTOMIZE
SESSION_NAME="agent"
RUN_SCRIPT="$REPO_DIR/scripts/run-agent.sh"
DETACH=false

[ "${1:-}" = "--detach" ] && DETACH=true

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
  exit 1
fi

# Start tmux session with auto-respawning agent
tmux new-session -d -s "$SESSION_NAME" -n main -c "$REPO_DIR" \
  "while true; do $RUN_SCRIPT; echo '--- Agent exited. Restarting in 30s (Ctrl+C to stop) ---'; sleep 30; done"

# Utility windows
tmux new-window -t "$SESSION_NAME" -n logs -c "$REPO_DIR" \
  "tail -f $REPO_DIR/logs/agent.log 2>/dev/null || echo 'No log file yet.' && sleep infinity"
tmux new-window -t "$SESSION_NAME" -n shell -c "$REPO_DIR"

tmux select-window -t "$SESSION_NAME":main

echo "Agent Environment started."

if [ "$DETACH" = false ]; then
  exec tmux attach-session -t "$SESSION_NAME"
fi
