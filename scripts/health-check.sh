#!/usr/bin/env bash
# health-check.sh — Agent CEO health monitor
# Usage: health-check.sh [--quiet]
#   --quiet: only produce output when status is not HEALTHY (cron-friendly)
# Env: REPO_DIR, SESSION_NAME, PROGRESS_FILE, STALE_THRESHOLD_HOURS,
#      SLACK_ALERTS=true to post non-healthy results via notify-slack.sh

set -euo pipefail

# ─── Configuration ──────────────────────────────────────────────────────────
# Project root defaults to the parent of this script's directory
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SESSION_NAME="${SESSION_NAME:-agent}"
PROGRESS_FILE="${PROGRESS_FILE:-agent-progress.txt}"
STALE_THRESHOLD_HOURS="${STALE_THRESHOLD_HOURS:-24}"
SLACK_ALERTS="${SLACK_ALERTS:-false}"   # set to true to alert via notify-slack.sh
# ────────────────────────────────────────────────────────────────────────────

QUIET=false
[[ "${1:-}" == "--quiet" ]] && QUIET=true

NOW_EPOCH=$(date +%s)
NOW_DISPLAY=$(date '+%Y-%m-%d %H:%M')
STATUS="HEALTHY"
EXIT_CODE=0

# Helpers ────────────────────────────────────────────────────────────────────

hours_ago() {
  local file_epoch="$1"
  local diff=$(( NOW_EPOCH - file_epoch ))
  local hours=$(( diff / 3600 ))
  echo "$hours"
}

friendly_age() {
  local h="$1"
  if (( h < 1 )); then
    echo "<1h ago"
  elif (( h < 24 )); then
    echo "${h}h ago"
  else
    local days=$(( h / 24 ))
    echo "${days}d ago"
  fi
}

degrade() {
  if [[ "$STATUS" != "DOWN" ]]; then
    STATUS="DEGRADED"
    EXIT_CODE=1
  fi
  return 0  # never trip `set -e`
}

mark_down() {
  STATUS="DOWN"
  EXIT_CODE=2
}

# ─── Check 1: tmux session ─────────────────────────────────────────────────

SESSION_LINE=""
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  SESSION_PID=$(tmux list-sessions -F '#{session_name} #{pid}' 2>/dev/null \
    | grep "^${SESSION_NAME} " | awk '{print $2}' || true)
  if [[ -n "$SESSION_PID" ]]; then
    SESSION_LINE="$(printf '%-15s ✓ Running (pid %s)' 'Session:' "$SESSION_PID")"
  else
    SESSION_LINE="$(printf '%-15s ✓ Running' 'Session:')"
  fi
else
  SESSION_LINE="$(printf '%-15s ✗ Not running' 'Session:')"
  mark_down
fi

# ─── Check 2: progress file freshness ──────────────────────────────────────

PROGRESS_PATH="$REPO_DIR/$PROGRESS_FILE"
PROGRESS_LINE=""
if [[ -f "$PROGRESS_PATH" ]]; then
  PROG_EPOCH=$(stat -c '%Y' "$PROGRESS_PATH" 2>/dev/null || stat -f '%m' "$PROGRESS_PATH" 2>/dev/null)
  PROG_HOURS=$(hours_ago "$PROG_EPOCH")
  PROG_AGE=$(friendly_age "$PROG_HOURS")
  if (( PROG_HOURS >= STALE_THRESHOLD_HOURS )); then
    PROGRESS_LINE="$(printf '%-15s ⚠ Stale (%s)' 'Progress file:' "$PROG_AGE")"
    degrade
  else
    PROGRESS_LINE="$(printf '%-15s ✓ Updated %s' 'Progress file:' "$PROG_AGE")"
  fi
else
  PROGRESS_LINE="$(printf '%-15s ⚠ File not found' 'Progress file:')"
  degrade
fi

# ─── Check 3: last daily report ────────────────────────────────────────────

REPORTS_DIR="$REPO_DIR/daily-reports"
REPORT_LINE=""
TODAY=$(date '+%Y-%m-%d')
if [[ -d "$REPORTS_DIR" ]]; then
  LATEST_REPORT=$(find "$REPORTS_DIR" -maxdepth 1 -name '*.md' 2>/dev/null | sort -r | head -n1 || true)
  if [[ -n "$LATEST_REPORT" ]]; then
    REPORT_DATE=$(basename "$LATEST_REPORT" .md)
    if [[ "$REPORT_DATE" == "$TODAY" ]]; then
      REPORT_LINE="$(printf '%-15s ✓ %s' 'Last report:' "$REPORT_DATE")"
    else
      REPORT_LINE="$(printf '%-15s ⚠ Missing today (latest: %s)' 'Last report:' "$REPORT_DATE")"
      degrade
    fi
  else
    REPORT_LINE="$(printf '%-15s ⚠ No reports found' 'Last report:')"
    degrade
  fi
else
  REPORT_LINE="$(printf '%-15s ⚠ Reports directory missing' 'Last report:')"
  degrade
fi

# ─── Check 4: last git commit ──────────────────────────────────────────────

COMMIT_LINE=""
if git -C "$REPO_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  COMMIT_EPOCH=$(git -C "$REPO_DIR" log -1 --format='%ct' 2>/dev/null || echo "0")
  if [[ "$COMMIT_EPOCH" != "0" ]]; then
    COMMIT_HOURS=$(hours_ago "$COMMIT_EPOCH")
    COMMIT_AGE=$(friendly_age "$COMMIT_HOURS")
    if (( COMMIT_HOURS >= STALE_THRESHOLD_HOURS )); then
      COMMIT_LINE="$(printf '%-15s ⚠ %s' 'Last commit:' "$COMMIT_AGE")"
      degrade
    else
      COMMIT_LINE="$(printf '%-15s ✓ %s' 'Last commit:' "$COMMIT_AGE")"
    fi
  else
    COMMIT_LINE="$(printf '%-15s ⚠ No commits' 'Last commit:')"
    degrade
  fi
else
  COMMIT_LINE="$(printf '%-15s ⚠ Not a git repo' 'Last commit:')"
  degrade
fi

# ─── Check 5: lessons-learned file ─────────────────────────────────────────

LESSONS_PATH="$REPO_DIR/lessons-learned.md"
LESSONS_LINE=""
if [[ -f "$LESSONS_PATH" ]]; then
  # grep -c prints 0 AND exits 1 on no match; don't append a second "0"
  ENTRY_COUNT=$(grep -c '^- \[' "$LESSONS_PATH" 2>/dev/null || true)
  ENTRY_COUNT=${ENTRY_COUNT:-0}
  if (( ENTRY_COUNT > 0 )); then
    LESSONS_LINE="$(printf '%-15s ✓ %d entries' 'Lessons file:' "$ENTRY_COUNT")"
  else
    LESSONS_LINE="$(printf '%-15s ⚠ Empty' 'Lessons file:')"
    degrade
  fi
else
  LESSONS_LINE="$(printf '%-15s ⚠ File not found' 'Lessons file:')"
  degrade
fi

# ─── Output ─────────────────────────────────────────────────────────────────

if [[ "$QUIET" == true && "$STATUS" == "HEALTHY" ]]; then
  exit 0
fi

SEPARATOR="═══════════════════════════════════════"

cat <<EOM
Agent Health Check — $NOW_DISPLAY
$SEPARATOR
$SESSION_LINE
$PROGRESS_LINE
$REPORT_LINE
$COMMIT_LINE
$LESSONS_LINE
$SEPARATOR
Status: $STATUS
EOM

# ─── Slack alert on non-healthy status ──────────────────────────────────────

if [[ "$SLACK_ALERTS" == true && "$STATUS" != "HEALTHY" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  NOTIFY_SCRIPT="$SCRIPT_DIR/notify-slack.sh"
  if [[ -x "$NOTIFY_SCRIPT" ]]; then
    "$NOTIFY_SCRIPT" "Agent health: $STATUS — $SESSION_LINE | $PROGRESS_LINE | $REPORT_LINE | $COMMIT_LINE | $LESSONS_LINE" 2>/dev/null || true
  fi
fi

exit $EXIT_CODE
