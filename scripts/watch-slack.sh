#!/bin/bash
# Watch Slack for new stakeholder messages.
# Runs via cron every 15 minutes.
#
# When a new message is detected:
#   1. Logs to logs/stakeholder-messages.log
#   2. Appends to agent-progress.txt so the next session sees it
#   3. Sends acknowledgment to Slack if no active session
#
# Setup:
#   1. Create ~/.config/your-project/slack.env with:
#      SLACK_BOT_TOKEN=xoxb-your-token
#      SLACK_CHANNEL_ID=C0YOUR_CHANNEL
#      SLACK_BOT_USER_ID=U0YOUR_BOT
#   2. Add to cron: */15 * * * * /path/to/watch-slack.sh

set -uo pipefail

# CUSTOMIZE these paths
REPO_DIR=~/dev/your-project
SLACK_CONFIG="$HOME/.config/your-project/slack.env"
SESSION_NAME="agent"  # tmux session name from start-agent.sh

PROGRESS_FILE="$REPO_DIR/agent-progress.txt"
LOG_DIR="$REPO_DIR/logs"
LOG_FILE="$LOG_DIR/stakeholder-messages.log"
LAST_CHECK_FILE="$LOG_DIR/.last-slack-check"

mkdir -p "$LOG_DIR"

# Load Slack config
if [ ! -f "$SLACK_CONFIG" ]; then
  exit 0  # Silent — no config means Slack not set up
fi
source "$SLACK_CONFIG"

if [ -z "${SLACK_BOT_TOKEN:-}" ] || [ -z "${SLACK_CHANNEL_ID:-}" ]; then
  exit 0
fi

# Get last check timestamp
if [ -f "$LAST_CHECK_FILE" ]; then
  SINCE=$(cat "$LAST_CHECK_FILE")
else
  SINCE=$(date -d '24 hours ago' +%s 2>/dev/null || date -v-24H +%s 2>/dev/null || echo "0")
fi

# Update timestamp
date +%s > "$LAST_CHECK_FILE"

# Fetch channel history
RESPONSE=$(curl -s -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
  "https://slack.com/api/conversations.history?channel=${SLACK_CHANNEL_ID}&oldest=${SINCE}&limit=50")

# Extract human messages
MESSAGES=$(echo "$RESPONSE" | python3 -c "
import sys, json, datetime

data = json.load(sys.stdin)
if not data.get('ok'):
    sys.exit(1)

bot_user_id = '${SLACK_BOT_USER_ID:-}'
messages = data.get('messages', [])

human_msgs = []
for msg in messages:
    if msg.get('bot_id') or msg.get('subtype') == 'bot_message':
        continue
    if msg.get('user') == bot_user_id:
        continue
    if msg.get('subtype'):
        continue
    human_msgs.append(msg)

if not human_msgs:
    sys.exit(1)

for msg in reversed(human_msgs):
    ts = float(msg['ts'])
    dt = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M')
    text = msg.get('text', '').replace('\n', ' | ')
    print(f'[{dt}]: {text}')
" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$MESSAGES" ]; then
  exit 0  # No new messages
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log
echo "" >> "$LOG_FILE"
echo "=== Stakeholder Messages: $TIMESTAMP ===" >> "$LOG_FILE"
echo "$MESSAGES" >> "$LOG_FILE"

# Surface to agent via progress file
echo "" >> "$PROGRESS_FILE"
echo "[STAKEHOLDER-MESSAGE $(date '+%Y-%m-%d %H:%M')] New message detected:" >> "$PROGRESS_FILE"
echo "$MESSAGES" >> "$PROGRESS_FILE"

# Notify if no active session
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  # Send Slack acknowledgment via webhook if configured
  if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
    curl -s -X POST "$SLACK_WEBHOOK_URL" \
      -H 'Content-type: application/json' \
      -d '{"text": "Message received (no active session). Will be processed on next session start."}' >/dev/null 2>&1
  fi
fi
