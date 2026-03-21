#!/bin/bash
# Send a message to your Slack channel.
# Usage: notify-slack.sh "Your message here"

MESSAGE="${1:-No message provided}"

# CUSTOMIZE: path to your slack config
SLACK_CONFIG="$HOME/.config/your-project/slack.env"

if [ ! -f "$SLACK_CONFIG" ]; then
  echo "ERROR: Slack config not found at $SLACK_CONFIG" >&2
  exit 1
fi
source "$SLACK_CONFIG"

if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  echo "ERROR: SLACK_WEBHOOK_URL not set" >&2
  exit 1
fi

curl -s -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-type: application/json' \
  -d "{\"text\": \"${MESSAGE}\"}" >/dev/null 2>&1
